from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


ServiceOrderStatus = Literal["open", "in_progress", "done", "cancelled"]
ServiceOrderPriority = Literal["low", "medium", "high"]


class ServiceOrderBase(BaseModel):
    title: str = Field(min_length=3, max_length=120)
    description: str = Field(min_length=5)
    customer_name: str = Field(min_length=2, max_length=120)
    status: ServiceOrderStatus = "open"
    priority: ServiceOrderPriority = "medium"


class ServiceOrderCreate(ServiceOrderBase):
    pass


class ServiceOrderUpdate(BaseModel):
    title: str | None = Field(default=None, min_length=3, max_length=120)
    description: str | None = Field(default=None, min_length=5)
    customer_name: str | None = Field(default=None, min_length=2, max_length=120)
    status: ServiceOrderStatus | None = None
    priority: ServiceOrderPriority | None = None


class ServiceOrderRead(ServiceOrderBase):
    id: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)