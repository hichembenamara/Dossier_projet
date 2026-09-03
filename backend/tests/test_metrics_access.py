"""/metrics est réservé aux réseaux de supervision (réseau Docker interne, boucle locale)."""
from __future__ import annotations

from fastapi.testclient import TestClient

from app.main import app


def _get_metrics(client_host: str) -> int:
    with TestClient(app, client=(client_host, 50000)) as client:
        return client.get("/metrics").status_code


def test_metrics_allowed_from_docker_network():
    assert _get_metrics("172.18.0.5") == 200


def test_metrics_allowed_from_loopback():
    assert _get_metrics("127.0.0.1") == 200


def test_metrics_forbidden_from_public_address():
    assert _get_metrics("203.0.113.7") == 403


def test_metrics_forbidden_when_client_address_unknown():
    assert _get_metrics("testclient") == 403
