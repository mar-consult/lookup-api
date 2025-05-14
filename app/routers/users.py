import logging
from fastapi import APIRouter, Request, status, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi.responses import JSONResponse
from os import getenv
import requests
from sqlalchemy import select, desc
from app.models.database import get_db

from app.models.users import (
    UserModel,
    LookupResponse
)

router = APIRouter()

logger = logging.getLogger(__name__)

URL_PATH = "https://person.clearbit.com/v2/people/find"
HEADERS = {'Authorization': f'Bearer {getenv("TOKEN")}'}

@router.get(
    "/lookup",
    status_code=status.HTTP_200_OK,
    response_model=LookupResponse
)
async def lookup(request: Request, email: str, db: AsyncSession = Depends(get_db)):
    
    api_request = requests.get(url=URL_PATH, headers=HEADERS, params={"email": email})
    if api_request.status_code != 200:
        return JSONResponse(content={"message": f"User with email {email} not found"}, status_code=status.HTTP_404_NOT_FOUND)
    
    data = api_request.json()

    query = await db.scalars(
            select(
                UserModel
            ).select_from(UserModel).where(UserModel.email == email)
    )
    
    user  = query.first()

    if user == None:
        db.add(UserModel(email=email, num_of_hits=1))
        await db.flush()
        await db.commit()
        return LookupResponse(
                name=data["name"]["fullName"],
                email=email,
                location=data["location"],
                image_url=data["avatar"],
                num_of_hits=1
            )
    user.num_of_hits = user.num_of_hits + 1
    await db.flush()
    await db.commit()
    return LookupResponse(
                name=data["name"]["fullName"],
                email=email,
                location=data["location"],
                image_url=data["avatar"],
                num_of_hits=user.num_of_hits
            )


@router.get(
    "/popularity",
    status_code=status.HTTP_200_OK
)
async def popularity(request: Request, db: AsyncSession = Depends(get_db)):
    
    query = await db.scalars(
            select(
                UserModel.email
            ).select_from(UserModel).order_by(desc(UserModel.num_of_hits)).limit(10)
    )
    
    users  = query.all()

    return users


