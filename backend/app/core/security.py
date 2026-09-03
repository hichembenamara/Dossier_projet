from __future__ import annotations

import base64
import hashlib
import hmac
import secrets
from datetime import datetime, timedelta, timezone
from typing import Any

import jwt
from fastapi import Cookie, Depends, Header
from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import ApiError
from app.db.models import Utilisateur
from app.db.session import get_db


PBKDF2_ITERATIONS = 600_000  # OWASP Password Storage Cheat Sheet (PBKDF2-HMAC-SHA256)


def hash_password_pbkdf2_sha256(password: str, salt: str | None = None, iterations: int = PBKDF2_ITERATIONS) -> str:
    salt = salt or secrets.token_urlsafe(12)
    digest = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt.encode("utf-8"), iterations)
    digest_b64 = base64.b64encode(digest).decode("ascii").strip()
    return f"pbkdf2_sha256${iterations}${salt}${digest_b64}"


def verify_password(password: str, encoded: str | None) -> bool:
    if not encoded:
        return False
    try:
        algorithm, iterations_raw, salt, expected = encoded.split("$", 3)
        if algorithm != "pbkdf2_sha256":
            return False
        candidate = hash_password_pbkdf2_sha256(password, salt=salt, iterations=int(iterations_raw))
        return hmac.compare_digest(candidate, encoded)
    except (ValueError, TypeError):
        return False


def create_token(subject: str, token_type: str, expires_delta: timedelta, extra: dict[str, Any] | None = None) -> str:
    settings = get_settings()
    now = datetime.now(timezone.utc)
    payload = {
        "sub": subject,
        "type": token_type,
        "iat": now,
        "exp": now + expires_delta,
        **(extra or {}),
    }
    return jwt.encode(payload, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)


def decode_token(token: str, expected_type: str) -> dict[str, Any]:
    settings = get_settings()
    try:
        payload = jwt.decode(
            token,
            settings.jwt_secret_key,
            algorithms=[settings.jwt_algorithm],
            options={"require": ["exp", "sub", "type"]},
        )
    except jwt.PyJWTError:
        raise ApiError(401, "unauthorized", "Token invalide ou expire.")
    if payload.get("type") != expected_type:
        raise ApiError(401, "unauthorized", "Token invalide ou expire.")
    return payload


def authenticate_user(db: Session, identifiant: str, mot_de_passe: str) -> Utilisateur | None:
    user = db.execute(
        select(Utilisateur).where(
            or_(Utilisateur.email == identifiant, Utilisateur.nom_utilisateur == identifiant)
        )
    ).scalar_one_or_none()
    if not user or user.statut != "ACTIF" or not verify_password(mot_de_passe, user.mot_de_passe_hash):
        return None
    return user


def current_user(
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db),
) -> Utilisateur:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise ApiError(401, "unauthorized", "Authentification requise.")
    payload = decode_token(authorization.split(" ", 1)[1], "access")
    user = db.get(Utilisateur, int(payload["sub"]))
    if not user or user.statut != "ACTIF":
        raise ApiError(401, "unauthorized", "Utilisateur introuvable ou inactif.")
    return user


def current_user_from_refresh(
    refresh_token: str | None = Cookie(default=None),
    db: Session = Depends(get_db),
) -> Utilisateur:
    if not refresh_token:
        raise ApiError(401, "unauthorized", "Refresh token manquant.")
    payload = decode_token(refresh_token, "refresh")
    user = db.get(Utilisateur, int(payload["sub"]))
    if not user or user.statut != "ACTIF":
        raise ApiError(401, "unauthorized", "Utilisateur introuvable ou inactif.")
    return user


def require_roles(*roles: str):
    def dependency(user: Utilisateur = Depends(current_user)) -> Utilisateur:
        if user.role not in roles:
            raise ApiError(403, "forbidden", "Droits insuffisants.")
        return user

    return dependency
