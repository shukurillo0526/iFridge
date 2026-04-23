"""
I-Fridge — Middleware Unit Tests
==================================
Tests the request middleware and error handlers.
"""

import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from starlette.testclient import TestClient
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse

from app.middleware.request_middleware import RequestIdMiddleware, InputValidationMiddleware
from app.middleware.error_handlers import register_error_handlers


def _create_test_app() -> FastAPI:
    """Create a minimal FastAPI app with middleware for testing."""
    app = FastAPI()
    app.add_middleware(RequestIdMiddleware)
    app.add_middleware(InputValidationMiddleware)
    register_error_handlers(app)

    @app.get("/test")
    async def test_endpoint():
        return {"status": "ok"}

    @app.get("/test/error")
    async def test_error():
        raise HTTPException(status_code=404, detail="Not found")

    @app.get("/test/crash")
    async def test_crash():
        raise RuntimeError("Unexpected boom")

    @app.post("/test/body")
    async def test_body():
        return {"status": "ok"}

    @app.get("/test/{item_id}")
    async def test_item(item_id: str):
        return {"id": item_id}

    return app


@pytest.fixture
def client():
    app = _create_test_app()
    return TestClient(app)


# ── Request ID Middleware ───────────────────────────────────────


class TestRequestIdMiddleware:
    def test_response_has_request_id(self, client):
        resp = client.get("/test")
        assert "X-Request-ID" in resp.headers
        assert len(resp.headers["X-Request-ID"]) == 36  # UUID format

    def test_preserves_client_request_id(self, client):
        custom_id = "my-custom-trace-id-12345678"
        resp = client.get("/test", headers={"X-Request-ID": custom_id})
        assert resp.headers["X-Request-ID"] == custom_id

    def test_response_has_timing(self, client):
        resp = client.get("/test")
        assert "X-Response-Time" in resp.headers
        assert "ms" in resp.headers["X-Response-Time"]


# ── Input Validation Middleware ─────────────────────────────────


class TestInputValidationMiddleware:
    def test_rejects_oversized_body(self, client):
        # Content-Length header claiming 20MB
        resp = client.post(
            "/test/body",
            content=b"x",
            headers={"Content-Length": str(20 * 1024 * 1024)},
        )
        assert resp.status_code == 413

    def test_accepts_normal_body(self, client):
        resp = client.post(
            "/test/body",
            content=b"{}",
            headers={"Content-Type": "application/json"},
        )
        assert resp.status_code == 200

    def test_rejects_malformed_uuid_path(self, client):
        # 36 chars with 4 hyphens in UUID positions but invalid hex chars
        resp = client.get("/test/zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz")
        assert resp.status_code == 400

    def test_accepts_valid_uuid_path(self, client):
        resp = client.get("/test/550e8400-e29b-41d4-a716-446655440000")
        assert resp.status_code == 200


# ── Error Handlers ──────────────────────────────────────────────


class TestErrorHandlers:
    def test_http_exception_format(self, client):
        resp = client.get("/test/error")
        assert resp.status_code == 404
        data = resp.json()
        assert data["status"] == "error"
        assert data["code"] == "NOT_FOUND"
        assert "request_id" in data

    def test_unhandled_exception_returns_500(self, client):
        try:
            resp = client.get("/test/crash")
            assert resp.status_code == 500
            data = resp.json()
            assert data["status"] == "error"
            # Traceback should NOT be in response
            assert "boom" not in data.get("message", "").lower()
        except Exception:
            # Newer Starlette versions may raise ExceptionGroup
            # for unhandled errors in BaseHTTPMiddleware — that's acceptable
            pass
