from os import getenv
from sqlalchemy.ext.asyncio import (
    create_async_engine,
    async_sessionmaker,
    AsyncSession)


def get_database_connection_url():
    USERNAME = getenv("POSTGRES_USERNAME")
    PASSWORD = getenv("POSTGRES_PASSWORD")
    HOST = getenv("POSTGRES_HOST")
    PORT = getenv("POSTGRES_PORT", default=5432)
    DBNAME = "postgres"

    return f"postgresql+asyncpg://{USERNAME}:{PASSWORD}@{HOST}:{PORT}/{DBNAME}"


engine = create_async_engine(get_database_connection_url(), pool_size=20,
                             max_overflow=0,
                             pool_recycle=3600,
                             pool_timeout=5,
                             pool_pre_ping=True
                             )

db_session = async_sessionmaker(
    bind=engine,
    autocommit=False,
    autoflush=True,
    expire_on_commit=False,
    class_=AsyncSession
)


async def get_db():
    async with db_session() as session:
        yield session
