import logging

from fastapi import APIRouter, status

router = APIRouter()

logger = logging.getLogger(__name__)


@router.get("/health", status_code=status.HTTP_200_OK)
def health():
    return {"status": "Ok"}
