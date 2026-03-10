from fastapi import APIRouter, Depends, HTTPException, Query, File, UploadFile
from fastapi.security import HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from typing import List
import models
import schemas
import crud
from database import get_db
from auth import get_current_admin_user, security
import uuid
import os
import shutil
from datetime import datetime

# Dependency function for admin authentication
def get_admin_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    return get_current_admin_user(credentials, db)

router = APIRouter()

# ==================== ABOUT CONTENT ENDPOINTS ====================

@router.get("/", response_model=schemas.About)
async def get_about(db: Session = Depends(get_db)):
    """Get about information"""
    try:
        about = db.query(models.About).first()
        if not about:
            raise HTTPException(status_code=404, detail="About information not found")
        return about
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve about information: {str(e)}")

@router.post("/", response_model=schemas.About)
async def create_about(
    about: schemas.AboutCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_admin_user)
):
    """Create about information (admin only)"""
    try:
        # Check if about already exists
        existing_about = db.query(models.About).first()
        if existing_about:
            raise HTTPException(status_code=400, detail="About information already exists. Use PUT to update.")
        
        about_data = about.dict()
        about_data['id'] = str(uuid.uuid4())
        db_about = crud.create_item(db, models.About, about_data)
        return db_about
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create about information: {str(e)}")

@router.put("/", response_model=schemas.About)
async def update_about(
    about: schemas.AboutCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_admin_user)
):
    """Update about information (admin only)"""
    try:
        db_about = db.query(models.About).first()
        if not db_about:
            raise HTTPException(status_code=404, detail="About information not found")
        
        updated_about = crud.update_item(db, db_about, about.dict())
        return updated_about
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update about information: {str(e)}")

@router.delete("/")
async def delete_about(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_admin_user)
):
    """Delete about information (admin only)"""
    try:
        db_about = db.query(models.About).first()
        if not db_about:
            raise HTTPException(status_code=404, detail="About information not found")
        
        crud.delete_item(db, db_about)
        return {"message": "About information deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete about information: {str(e)}")

# ==================== CEO MANAGEMENT ENDPOINTS ====================

@router.get("/ceos", response_model=List[schemas.CEO])
async def get_ceos(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db)
):
    """Get all CEOs ordered by display_order"""
    try:
        ceos = crud.get_ceos(db, skip=skip, limit=limit)
        return ceos
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve CEOs: {str(e)}")

@router.get("/ceos/{ceo_id}", response_model=schemas.CEO)
async def get_ceo(
    ceo_id: str,
    db: Session = Depends(get_db)
):
    """Get a specific CEO by ID"""
    try:
        ceo = crud.get_ceo(db, ceo_id)
        if not ceo:
            raise HTTPException(status_code=404, detail="CEO not found")
        return ceo
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve CEO: {str(e)}")

@router.post("/ceos", response_model=schemas.CEO)
async def create_ceo(
    ceo: schemas.CEOCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_admin_user)
):
    """Add new CEO (admin only)"""
    try:
        db_ceo = crud.create_ceo(db, ceo)
        return db_ceo
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create CEO: {str(e)}")

@router.put("/ceos/{ceo_id}", response_model=schemas.CEO)
async def update_ceo(
    ceo_id: str,
    ceo_update: schemas.CEOUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_admin_user)
):
    """Update CEO information (admin only)"""
    try:
        db_ceo = crud.get_ceo(db, ceo_id)
        if not db_ceo:
            raise HTTPException(status_code=404, detail="CEO not found")
        
        updated_ceo = crud.update_ceo(db, db_ceo, ceo_update)
        return updated_ceo
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update CEO: {str(e)}")

@router.delete("/ceos/{ceo_id}")
async def delete_ceo(
    ceo_id: str,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_admin_user)
):
    """Delete CEO (admin only)"""
    try:
        db_ceo = crud.get_ceo(db, ceo_id)
        if not db_ceo:
            raise HTTPException(status_code=404, detail="CEO not found")
        
        crud.delete_ceo(db, db_ceo)
        return {"message": "CEO deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete CEO: {str(e)}")

# ==================== SUPPORTER MANAGEMENT ENDPOINTS ====================

@router.get("/supporters", response_model=List[schemas.Supporter])
async def get_supporters(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db)
):
    """Get all supporters ordered by display_order"""
    try:
        supporters = crud.get_supporters(db, skip=skip, limit=limit)
        return supporters
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve supporters: {str(e)}")

@router.get("/supporters/{supporter_id}", response_model=schemas.Supporter)
async def get_supporter(
    supporter_id: str,
    db: Session = Depends(get_db)
):
    """Get a specific supporter by ID"""
    try:
        supporter = crud.get_supporter(db, supporter_id)
        if not supporter:
            raise HTTPException(status_code=404, detail="Supporter not found")
        return supporter
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve supporter: {str(e)}")

@router.post("/supporters", response_model=schemas.Supporter)
async def create_supporter(
    supporter: schemas.SupporterCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_admin_user)
):
    """Add new supporter (admin only)"""
    try:
        db_supporter = crud.create_supporter(db, supporter)
        return db_supporter
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create supporter: {str(e)}")

@router.put("/supporters/{supporter_id}", response_model=schemas.Supporter)
async def update_supporter(
    supporter_id: str,
    supporter_update: schemas.SupporterUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_admin_user)
):
    """Update supporter information (admin only)"""
    try:
        db_supporter = crud.get_supporter(db, supporter_id)
        if not db_supporter:
            raise HTTPException(status_code=404, detail="Supporter not found")
        
        updated_supporter = crud.update_supporter(db, db_supporter, supporter_update)
        return updated_supporter
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update supporter: {str(e)}")

@router.delete("/supporters/{supporter_id}")
async def delete_supporter(
    supporter_id: str,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_admin_user)
):
    """Delete supporter (admin only)"""
    try:
        db_supporter = crud.get_supporter(db, supporter_id)
        if not db_supporter:
            raise HTTPException(status_code=404, detail="Supporter not found")
        
        crud.delete_supporter(db, db_supporter)
        return {"message": "Supporter deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete supporter: {str(e)}")

# ==================== IMAGE UPLOAD ENDPOINT ====================

@router.post("/upload-image")
async def upload_profile_image(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_admin_user)
):
    """Upload profile image for CEO or supporter (admin only)"""
    try:
        # Validate file type
        allowed_extensions = [".jpg", ".jpeg", ".png", ".webp"]
        file_ext = os.path.splitext(file.filename)[1].lower()
        
        if file_ext not in allowed_extensions:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid file type. Allowed: {', '.join(allowed_extensions)}"
            )
        
        # Create uploads directory if it doesn't exist
        upload_dir = "uploads/profiles"
        os.makedirs(upload_dir, exist_ok=True)
        
        # Generate unique filename
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{timestamp}_{uuid.uuid4().hex[:8]}{file_ext}"
        file_path = os.path.join(upload_dir, filename)
        
        # Save file
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        # Return URL (adjust based on your server configuration)
        image_url = f"/uploads/profiles/{filename}"
        
        return {
            "message": "Image uploaded successfully",
            "image_url": image_url,
            "filename": filename
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to upload image: {str(e)}")
