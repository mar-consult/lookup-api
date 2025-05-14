from fastapi import FastAPI
from app.routers import users, health


def build_app():
    app = FastAPI(
        title="Lookup API",
        description="""
        API for looking up email users
        """
    )

    app.include_router(health.router)
    app.include_router(users.router)

    return app
