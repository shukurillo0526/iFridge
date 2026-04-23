"""
I-Fridge — Global Error Handlers
==================================
Standardized exception handling across all endpoints.
Every error returns the same envelope shape:
  {"status": "error", "message": "...", "request_id": "...", "code": "..."}
"""

import logging
import traceback
from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

logger = logging.getLogger("ifridge.errors")

# Error code mapping for common HTTP status codes
ERROR_CODES = {
    400: "BAD_REQUEST",
    401: "UNAUTHORIZED",
    403: "FORBIDDEN",
    404: "NOT_FOUND",
    405: "METHOD_NOT_ALLOWED",
    409: "CONFLICT",
    413: "PAYLOAD_TOO_LARGE",
    422: "VALIDATION_ERROR",
    429: "RATE_LIMITED",
    500: "INTERNAL_ERROR",
    502: "BAD_GATEWAY",
    503: "SERVICE_UNAVAILABLE",
}


def _get_request_id(request: Request) -> str:
    """Extract request ID from state (set by middleware) or headers."""
    return getattr(request.state, "request_id", None) or \
           request.headers.get("X-Request-ID", "unknown")


def register_error_handlers(app: FastAPI) -> None:
    """
    Register all global exception handlers on the FastAPI app.
    Call this once during app initialization.
    """

    @app.exception_handler(StarletteHTTPException)
    async def http_exception_handler(request: Request, exc: StarletteHTTPException):
        """Handle all HTTP exceptions with standardized envelope."""
        request_id = _get_request_id(request)
        status = exc.status_code
        code = ERROR_CODES.get(status, "ERROR")

        logger.warning(
            f"[{code}] {exc.detail}",
            extra={"request_id": request_id, "status": status, "path": request.url.path},
        )

        return JSONResponse(
            status_code=status,
            content={
                "status": "error",
                "code": code,
                "message": str(exc.detail),
                "request_id": request_id,
            },
        )

    @app.exception_handler(RequestValidationError)
    async def validation_exception_handler(request: Request, exc: RequestValidationError):
        """Handle Pydantic validation errors with readable messages."""
        request_id = _get_request_id(request)

        # Build human-readable error messages
        errors = []
        for error in exc.errors():
            loc = " → ".join(str(l) for l in error.get("loc", []))
            msg = error.get("msg", "Invalid value")
            errors.append(f"{loc}: {msg}")

        logger.warning(
            f"[VALIDATION_ERROR] {len(errors)} field(s) failed",
            extra={"request_id": request_id, "errors": errors, "path": request.url.path},
        )

        return JSONResponse(
            status_code=422,
            content={
                "status": "error",
                "code": "VALIDATION_ERROR",
                "message": "Request validation failed",
                "errors": errors,
                "request_id": request_id,
            },
        )

    @app.exception_handler(Exception)
    async def unhandled_exception_handler(request: Request, exc: Exception):
        """
        Catch-all for unhandled exceptions.
        Logs the full traceback but returns a safe message to the client.
        """
        request_id = _get_request_id(request)

        logger.error(
            f"[UNHANDLED] {type(exc).__name__}: {exc}",
            extra={
                "request_id": request_id,
                "path": request.url.path,
                "traceback": traceback.format_exc(),
            },
        )

        return JSONResponse(
            status_code=500,
            content={
                "status": "error",
                "code": "INTERNAL_ERROR",
                "message": "An unexpected error occurred. Our team has been notified.",
                "request_id": request_id,
            },
        )
