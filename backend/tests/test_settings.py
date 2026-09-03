"""Contrôle de configuration au démarrage (fail-fast sur secret faible en production)."""
from __future__ import annotations

import pytest
from pydantic import ValidationError

from app.core.config import DEFAULT_JWT_SECRET, Settings

STRONG = "k" * 48


def test_settings_reject_default_secret_in_production():
    with pytest.raises(ValidationError, match="valeur par défaut"):
        Settings(environment="production", jwt_secret_key=DEFAULT_JWT_SECRET, _env_file=None)


def test_settings_reject_compose_placeholder_secret_in_production():
    with pytest.raises(ValidationError, match="valeur par défaut"):
        Settings(environment="production", jwt_secret_key="change-me-local-dev", _env_file=None)


def test_settings_reject_short_secret_in_production():
    with pytest.raises(ValidationError, match="trop courte"):
        Settings(environment="production", jwt_secret_key="court", _env_file=None)


def test_settings_accept_strong_secret_in_production():
    settings = Settings(environment="production", jwt_secret_key=STRONG, _env_file=None)
    assert settings.jwt_secret_key == STRONG


def test_settings_tolerate_default_secret_outside_production():
    settings = Settings(environment="development", jwt_secret_key=DEFAULT_JWT_SECRET, _env_file=None)
    assert settings.environment == "development"
