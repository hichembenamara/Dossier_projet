"""Tests de sécurité : jetons JWT (PyJWT), hachage des mots de passe, configuration.

Aucune base ni serveur requis : ces tests portent sur app.core.security et app.core.config.
"""
from __future__ import annotations

from datetime import timedelta

import jwt
import pytest

from app.core.config import get_settings
from app.core.errors import ApiError
from app.core.security import create_token, decode_token


def test_token_roundtrip_carries_subject_type_and_role():
    token = create_token("42", "access", timedelta(minutes=5), {"role": "ADMIN"})

    payload = decode_token(token, "access")

    assert payload["sub"] == "42"
    assert payload["type"] == "access"
    assert payload["role"] == "ADMIN"


def test_token_is_standard_jwt_readable_by_pyjwt():
    settings = get_settings()
    token = create_token("1", "access", timedelta(minutes=5))

    payload = jwt.decode(token, settings.jwt_secret_key, algorithms=[settings.jwt_algorithm])

    assert payload["sub"] == "1"
    assert "exp" in payload and "iat" in payload


def test_expired_token_is_rejected():
    token = create_token("1", "access", timedelta(seconds=-1))

    with pytest.raises(ApiError) as exc:
        decode_token(token, "access")
    assert exc.value.status_code == 401


def test_refresh_token_cannot_be_used_as_access_token():
    token = create_token("1", "refresh", timedelta(days=1))

    with pytest.raises(ApiError):
        decode_token(token, "access")


def test_token_signed_with_another_secret_is_rejected():
    settings = get_settings()
    forged = jwt.encode({"sub": "1", "type": "access", "exp": 4102444800}, "autre-secret", algorithm=settings.jwt_algorithm)

    with pytest.raises(ApiError):
        decode_token(forged, "access")


def test_unsigned_token_is_rejected():
    forged = jwt.encode({"sub": "1", "type": "access", "exp": 4102444800}, key=None, algorithm="none")

    with pytest.raises(ApiError):
        decode_token(forged, "access")
