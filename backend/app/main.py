from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from . import models
from .database import Base, engine
from .routes import router as service_orders_router


Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Service Orders API",
    description="Mini API para gerenciamento de ordens de serviço internas.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def read_root():
    return {
        "message": "Service Orders API is running.",
    }


app.include_router(service_orders_router)