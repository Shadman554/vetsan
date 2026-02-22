from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, ForeignKey, Float, JSON
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, index=True)
    username = Column(String(255), unique=True, index=True)
    email = Column(String(255), unique=True, index=True)
    hashed_password = Column(String(255))
    is_active = Column(Boolean, default=True)
    is_admin = Column(Boolean, default=False)
    total_points = Column(Integer, default=0)
    today_points = Column(Integer, default=0)
    photo_url = Column(String(1000), nullable=True)
    google_id = Column(String(255), nullable=True, unique=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    last_updated = Column(DateTime, default=datetime.utcnow)

class Book(Base):
    __tablename__ = "books"

    id = Column(String, primary_key=True, index=True)
    title = Column(String(500), index=True)
    description = Column(Text)
    category = Column(String(255), index=True)
    cover_url = Column(String(1000))
    download_url = Column(String(1000))
    added_at = Column(DateTime, default=datetime.utcnow)

class Disease(Base):
    __tablename__ = "diseases"

    id = Column(String, primary_key=True, index=True)
    name = Column(String(500), index=True)
    kurdish = Column(String(500), index=True)
    symptoms = Column(Text)
    cause = Column(Text)
    control = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)

class Drug(Base):
    __tablename__ = "drugs"

    id = Column(String, primary_key=True, index=True)
    name = Column(String(500), index=True)
    usage = Column(Text)
    side_effect = Column(Text)
    other_info = Column(Text)
    drug_class = Column(String(255), index=True)
    created_at = Column(DateTime, default=datetime.utcnow)

class DictionaryWord(Base):
    __tablename__ = "dictionary_words"

    id = Column(String, primary_key=True, index=True)
    name = Column(String(500), index=True)
    kurdish = Column(String(500), index=True)
    arabic = Column(String(500), index=True)
    description = Column(Text)
    barcode = Column(String(255))
    is_saved = Column(Boolean, default=False)
    is_favorite = Column(Boolean, default=False)

class Question(Base):
    __tablename__ = "questions"

    id = Column(String, primary_key=True, index=True)
    text = Column(Text)
    user_id = Column(String, ForeignKey("users.id"))
    user_name = Column(String(255))
    user_email = Column(String(255))
    user_photo = Column(String(1000))
    likes = Column(Integer, default=0)
    timestamp = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", backref="questions")

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(String, primary_key=True, index=True)
    title = Column(String(500))
    body = Column(Text)
    image_url = Column(String(1000))
    type = Column(String(255))
    is_read = Column(Boolean, default=False)
    timestamp = Column(DateTime, default=datetime.utcnow)

class Staff(Base):
    __tablename__ = "staff"

    id = Column(String, primary_key=True, index=True)
    name = Column(String(255))
    job = Column(String(255))
    description = Column(Text)
    photo = Column(String(1000))
    facebook = Column(String(1000))
    instagram = Column(String(1000))
    twitter = Column(String(1000))
    snapchat = Column(String(1000))

class Instrument(Base):
    __tablename__ = "instruments"

    id = Column(String, primary_key=True, index=True)
    name = Column(String(500), index=True)
    description = Column(Text)
    image_url = Column(String(1000))
    created_at = Column(DateTime, default=datetime.utcnow)

class Note(Base):
    __tablename__ = "notes"

    id = Column(String, primary_key=True, index=True)
    name = Column(String(500), index=True)
    description = Column(Text)
    image_url = Column(String(1000))
    created_at = Column(DateTime, default=datetime.utcnow)

class UrineSlide(Base):
    __tablename__ = "urine_slides"

    id = Column(String, primary_key=True, index=True)
    name = Column(String(500), index=True)
    species = Column(String(255), index=True)
    image_url = Column(String(1000))
    created_at = Column(DateTime, default=datetime.utcnow)

class StoolSlide(Base):
    __tablename__ = "stool_slides"

    id = Column(String, primary_key=True, index=True)
    name = Column(String(500), index=True)
    species = Column(String(255), index=True)
    image_url = Column(String(1000))
    created_at = Column(DateTime, default=datetime.utcnow)

class OtherSlide(Base):
    __tablename__ = "other_slides"

    id = Column(String, primary_key=True, index=True)
    name = Column(String(500), index=True)
    species = Column(String(255), index=True)
    image_url = Column(String(1000))
    created_at = Column(DateTime, default=datetime.utcnow)

class NormalRange(Base):
    __tablename__ = "normal_ranges"

    id = Column(String, primary_key=True, index=True)
    name = Column(String(500), index=True)
    species = Column(String(255), index=True)
    category = Column(String(255), index=True)
    unit = Column(String(50))
    min_value = Column(String(50))
    max_value = Column(String(50))

class AppLink(Base):
    __tablename__ = "app_links"

    id = Column(String, primary_key=True, index=True)
    url = Column(String(1000))

class About(Base):
    __tablename__ = "about"

    id = Column(String, primary_key=True, index=True)
    text = Column(Text)
    exported_at = Column(DateTime, default=datetime.utcnow)

class HaematologyTest(Base):
    __tablename__ = "haematology_tests"

    id = Column(String, primary_key=True, index=True)
    name = Column(String(500), index=True, unique=True)
    description = Column(Text)
    image_url = Column(String(1000))
    created_at = Column(DateTime, default=datetime.utcnow)

class SerologyTest(Base):
    __tablename__ = "serology_tests"

    id = Column(String, primary_key=True, index=True)
    name = Column(String(500), index=True, unique=True)
    description = Column(Text)
    image_url = Column(String(1000))
    created_at = Column(DateTime, default=datetime.utcnow)

class BiochemistryTest(Base):
    __tablename__ = "biochemistry_tests"

    id = Column(String, primary_key=True, index=True)
    name = Column(String(500), index=True, unique=True)
    description = Column(Text)
    image_url = Column(String(1000))
    created_at = Column(DateTime, default=datetime.utcnow)

class BacteriologyTest(Base):
    __tablename__ = "bacteriology_tests"

    id = Column(String, primary_key=True, index=True)
    name = Column(String(500), index=True, unique=True)
    description = Column(Text)
    image_url = Column(String(1000))
    created_at = Column(DateTime, default=datetime.utcnow)

class OtherTest(Base):
    __tablename__ = "other_tests"

    id = Column(String, primary_key=True, index=True)
    name = Column(String(500), index=True, unique=True)
    description = Column(Text)
    image_url = Column(String(1000))
    created_at = Column(DateTime, default=datetime.utcnow)