from fastapi import FastAPI, Depends, HTTPException, status, File, UploadFile, Query
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import List, Optional
from datetime import datetime
import uvicorn
import os
from contextlib import asynccontextmanager

from database import engine, get_db, check_db_connection, get_db_info
from models import Base
from api import (
    auth as auth_api, users, books, diseases, drugs, dictionary, 
    notifications, normal_ranges, 
    app_links, about, instruments, notes, urine_slides, stool_slides, other_slides, leaderboard,
    haematology_tests, serology_tests, biochemistry_tests, bacteriology_tests, other_tests,
    privacy_policy
)
from auth import verify_token
from config import settings
from logger import app_logger
from middleware import (
    LoggingMiddleware, 
    RateLimitMiddleware, 
    SecurityHeadersMiddleware,
    ErrorHandlingMiddleware
)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan events"""
    # Startup
    app_logger.info("🚀 Starting Veterinary Educational Platform API...")
    app_logger.info(f"Environment: {settings.ENVIRONMENT}")
    
    # Check database connection
    if check_db_connection():
        app_logger.info("✅ Database connection established")
        # Create database tables
        Base.metadata.create_all(bind=engine)
        app_logger.info("✅ Database tables created/verified")
    else:
        app_logger.error("❌ Failed to connect to database")
    
    yield
    
    # Shutdown
    app_logger.info("🛑 Shutting down Veterinary Educational Platform API...")
    engine.dispose()
    app_logger.info("✅ Database connections closed")

app = FastAPI(
    title="Veterinary Educational Platform API",
    version="3.0.0",
    description="Production-ready API for veterinary education with comprehensive features",
    docs_url="/docs" if settings.DEBUG else None,
    redoc_url="/redoc" if settings.DEBUG else None,
    lifespan=lifespan
)

# Add custom middleware (order matters!)
app.add_middleware(ErrorHandlingMiddleware)
app.add_middleware(SecurityHeadersMiddleware)
app.add_middleware(LoggingMiddleware)
app.add_middleware(RateLimitMiddleware, requests_per_minute=settings.RATE_LIMIT_REQUESTS)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

if settings.CORS_ORIGINS == ["*"]:
    app_logger.warning("⚠️  CORS is configured to allow all origins (*)")

# Security
security = HTTPBearer()

# Include routers
app.include_router(auth_api.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(books.router, prefix="/api/books", tags=["Books"])
app.include_router(diseases.router, prefix="/api/diseases", tags=["Diseases"])
app.include_router(drugs.router, prefix="/api/drugs", tags=["Drugs"])
app.include_router(dictionary.router, prefix="/api/dictionary", tags=["Dictionary"])
app.include_router(users.router, prefix="/api/users", tags=["Users"])
app.include_router(notifications.router, prefix="/api/notifications", tags=["Notifications"])
app.include_router(normal_ranges.router, prefix="/api/normal-ranges", tags=["Normal Ranges"])
app.include_router(app_links.router, prefix="/api/app-links", tags=["App Links"])
app.include_router(about.router, prefix="/api/about", tags=["About"])
app.include_router(instruments.router, prefix="/api/instruments", tags=["instruments"])
app.include_router(notes.router, prefix="/api/notes", tags=["notes"])
app.include_router(urine_slides.router, prefix="/api/urine-slides", tags=["urine-slides"])
app.include_router(stool_slides.router, prefix="/api/stool-slides", tags=["stool-slides"])
app.include_router(other_slides.router, prefix="/api/other-slides", tags=["other-slides"])
app.include_router(leaderboard.router, prefix="/api/leaderboard", tags=["leaderboard"])
app.include_router(haematology_tests.router, prefix="/api/haematology-tests", tags=["haematology-tests"])
app.include_router(serology_tests.router, prefix="/api/serology-tests", tags=["serology-tests"])
app.include_router(biochemistry_tests.router, prefix="/api/biochemistry-tests", tags=["biochemistry-tests"])
app.include_router(bacteriology_tests.router, prefix="/api/bacteriology-tests", tags=["bacteriology-tests"])
app.include_router(other_tests.router, prefix="/api/other-tests", tags=["other-tests"])
app.include_router(privacy_policy.router, prefix="/api/privacy-policy", tags=["Privacy Policy"])

@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "message": "Veterinary Educational Platform API",
        "version": "3.0.0",
        "status": "operational",
        "environment": settings.ENVIRONMENT,
        "docs": "/docs" if settings.DEBUG else "disabled in production"
    }

@app.get("/health")
async def health_check(db: Session = Depends(get_db)):
    """Comprehensive health check endpoint"""
    health_status = {
        "status": "healthy",
        "timestamp": str(datetime.utcnow()),
        "version": "3.0.0",
        "environment": settings.ENVIRONMENT
    }
    
    # Check database
    try:
        db.execute(text("SELECT 1"))
        health_status["database"] = "connected"
        health_status["database_info"] = get_db_info()
    except Exception as e:
        health_status["status"] = "unhealthy"
        health_status["database"] = "disconnected"
        health_status["error"] = str(e)
        app_logger.error(f"Health check failed: {str(e)}")
    
    return health_status

@app.get("/metrics")
async def metrics(db: Session = Depends(get_db)):
    """API metrics endpoint"""
    try:
        from models import User, DictionaryWord, Disease, Drug, Book
        
        metrics = {
            "users": db.query(User).count(),
            "dictionary_words": db.query(DictionaryWord).count(),
            "diseases": db.query(Disease).count(),
            "drugs": db.query(Drug).count(),
            "books": db.query(Book).count(),
            "database_info": get_db_info()
        }
        return metrics
    except Exception as e:
        app_logger.error(f"Metrics endpoint error: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to retrieve metrics")

if __name__ == "__main__":
    import os
    port = int(os.getenv("PORT", 5000))
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=port,
        reload=settings.DEBUG
    )