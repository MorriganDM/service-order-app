from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from .database import get_db
from .models import ServiceOrder
from .schemas import ServiceOrderCreate, ServiceOrderRead, ServiceOrderUpdate
from datetime import datetime

router = APIRouter(
    prefix="/service-orders",
    tags=["Service Orders"],
)


@router.get("", response_model=list[ServiceOrderRead])
def list_service_orders(db: Session = Depends(get_db)):
    return db.query(ServiceOrder).order_by(ServiceOrder.created_at.desc()).all()


@router.get("/{service_order_id}", response_model=ServiceOrderRead)
def get_service_order(service_order_id: int, db: Session = Depends(get_db)):
    service_order = (
        db.query(ServiceOrder)
        .filter(ServiceOrder.id == service_order_id)
        .first()
    )

    if service_order is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Service order not found.",
        )

    return service_order


@router.post(
    "",
    response_model=ServiceOrderRead,
    status_code=status.HTTP_201_CREATED,
)
def create_service_order(
    service_order_data: ServiceOrderCreate,
    db: Session = Depends(get_db),
):
    service_order = ServiceOrder(**service_order_data.model_dump())

    db.add(service_order)
    db.commit()
    db.refresh(service_order)

    return service_order


@router.put("/{service_order_id}", response_model=ServiceOrderRead)
def update_service_order(
    service_order_id: int,
    service_order_data: ServiceOrderUpdate,
    db: Session = Depends(get_db),
):
    service_order = (
        db.query(ServiceOrder)
        .filter(ServiceOrder.id == service_order_id)
        .first()
    )

    if service_order is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Service order not found.",
        )

    update_data = service_order_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        setattr(service_order, field, value)

    service_order.updated_at = datetime.now()

    db.commit()
    db.refresh(service_order)

    return service_order


@router.delete(
    "/{service_order_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_service_order(service_order_id: int, db: Session = Depends(get_db)):
    service_order = (
        db.query(ServiceOrder)
        .filter(ServiceOrder.id == service_order_id)
        .first()
    )

    if service_order is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Service order not found.",
        )

    db.delete(service_order)
    db.commit()

    return None