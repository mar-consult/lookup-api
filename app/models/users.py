from pydantic import BaseModel
from typing import Optional
from sqlalchemy.orm import declarative_base
from sqlalchemy import Column, String, Integer

Base = declarative_base()

class UserModel(Base):
    __tablename__ = 'users'

    id = Column(Integer(), primary_key=True)
    email = Column(String(100), nullable=False, unique=True)
    num_of_hits = Column(Integer(), nullable=True, unique=False)

class LookupResponse(BaseModel):
    name: str
    email: str
    location: Optional[str] = None
    image_url: Optional[str] = None
    num_of_hits: int
