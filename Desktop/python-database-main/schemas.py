from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

# User schemas
class UserBase(BaseModel):
    username: str
    email: EmailStr

class UserCreate(UserBase):
    password: str
    google_id: Optional[str] = None
    photo_url: Optional[str] = None

class UserLogin(BaseModel):
    username: str
    password: str

class UserAdminUpdate(BaseModel):
    is_admin: Optional[bool] = None
    is_active: Optional[bool] = None

class UserCreateAdmin(BaseModel):
    username: str
    email: EmailStr
    password: str
    is_admin: bool = False

class PasswordChange(BaseModel):
    new_password: str

class PointsUpdate(BaseModel):
    points: int

class User(UserBase):
    id: str
    is_active: bool
    is_admin: bool
    total_points: int
    today_points: int
    photo_url: Optional[str] = None
    created_at: datetime
    last_updated: datetime
    google_id: Optional[str] = None

    class Config:
        from_attributes = True

# Book schemas
class BookBase(BaseModel):
    title: str
    description: Optional[str] = None
    category: str
    cover_url: Optional[str] = None
    download_url: Optional[str] = None

class BookCreate(BookBase):
    pass

class Book(BookBase):
    id: str
    added_at: datetime

    class Config:
        from_attributes = True

# Disease schemas
class DiseaseBase(BaseModel):
    name: str
    kurdish: Optional[str] = None
    symptoms: Optional[str] = None
    cause: Optional[str] = None
    control: Optional[str] = None

class DiseaseCreate(DiseaseBase):
    pass

class Disease(DiseaseBase):
    id: str
    created_at: datetime

    class Config:
        from_attributes = True

# Drug schemas
class DrugBase(BaseModel):
    name: str
    usage: Optional[str] = None
    side_effect: Optional[str] = None
    other_info: Optional[str] = None
    drug_class: Optional[str] = None
    trade_names: Optional[str] = None
    species_dosages: Optional[str] = None
    contraindications: Optional[str] = None
    drug_interactions: Optional[str] = None
    withdrawal_times: Optional[str] = None

class DrugCreate(DrugBase):
    pass

class Drug(DrugBase):
    id: str
    created_at: datetime

    class Config:
        from_attributes = True

# Dictionary schemas
class DictionaryWordBase(BaseModel):
    name: str
    kurdish: Optional[str] = None
    arabic: Optional[str] = None
    description: Optional[str] = None
    barcode: Optional[str] = None
    is_saved: bool = False
    is_favorite: bool = False

class DictionaryWordCreate(DictionaryWordBase):
    pass

class DictionaryWord(DictionaryWordBase):
    id: str

    class Config:
        from_attributes = True

# Question schemas
class QuestionBase(BaseModel):
    text: str
    user_name: str
    user_email: str
    user_photo: Optional[str] = None

class QuestionCreate(QuestionBase):
    pass

class Question(QuestionBase):
    id: str
    user_id: str
    likes: int
    timestamp: datetime

    class Config:
        from_attributes = True

# Notification schemas
class NotificationBase(BaseModel):
    title: str
    body: str
    image_url: Optional[str] = None
    type: Optional[str] = None

class NotificationCreate(NotificationBase):
    pass

class Notification(NotificationBase):
    id: str
    is_read: bool = False
    timestamp: datetime

    class Config:
        from_attributes = True

# Staff schemas
class StaffBase(BaseModel):
    name: str
    job: str
    description: Optional[str] = None
    photo: Optional[str] = None
    facebook: Optional[str] = None
    instagram: Optional[str] = None
    twitter: Optional[str] = None
    snapchat: Optional[str] = None

class StaffCreate(StaffBase):
    pass

class Staff(StaffBase):
    id: str

    class Config:
        from_attributes = True

# Instrument schemas
class InstrumentBase(BaseModel):
    name: str
    category: Optional[str] = None
    description: Optional[str] = None
    image_url: Optional[str] = None

class InstrumentCreate(InstrumentBase):
    pass

class Instrument(InstrumentBase):
    id: str
    created_at: datetime

    class Config:
        from_attributes = True

# Note schemas
class NoteBase(BaseModel):
    name: str
    description: Optional[str] = None
    image_url: Optional[str] = None

class NoteCreate(NoteBase):
    pass

class Note(NoteBase):
    id: str
    created_at: datetime

    class Config:
        from_attributes = True

# Urine Slide schemas
class UrineSlideBase(BaseModel):
    name: str
    species: str
    image_url: Optional[str] = None

class UrineSlideCreate(UrineSlideBase):
    pass

class UrineSlide(UrineSlideBase):
    id: str
    created_at: datetime

    class Config:
        from_attributes = True

# Stool Slide schemas
class StoolSlideBase(BaseModel):
    name: str
    species: str
    image_url: Optional[str] = None

class StoolSlideCreate(StoolSlideBase):
    pass

class StoolSlide(StoolSlideBase):
    id: str
    created_at: datetime

    class Config:
        from_attributes = True

# Other Slide schemas
class OtherSlideBase(BaseModel):
    name: str
    species: str
    image_url: Optional[str] = None

class OtherSlideCreate(OtherSlideBase):
    pass

class OtherSlide(OtherSlideBase):
    id: str
    created_at: datetime

    class Config:
        from_attributes = True

# Normal Range schemas
class NormalRangeBase(BaseModel):
    name: str
    parameter: Optional[str] = None
    species: str
    category: str
    unit: str
    min_value: str
    max_value: str
    panic_low: Optional[str] = None
    panic_high: Optional[str] = None
    note: Optional[str] = None
    reference: Optional[str] = None

class NormalRangeCreate(NormalRangeBase):
    pass

class NormalRange(NormalRangeBase):
    id: str
    created_at: datetime

    class Config:
        from_attributes = True

# App Link schemas
class AppLinkBase(BaseModel):
    url: str

class AppLinkCreate(AppLinkBase):
    pass

class AppLink(AppLinkBase):
    id: str

    class Config:
        from_attributes = True

# About schemas
class AboutBase(BaseModel):
    text: str

class AboutCreate(AboutBase):
    pass

class About(AboutBase):
    id: str
    exported_at: datetime

    class Config:
        from_attributes = True

# CEO schemas
class CEOBase(BaseModel):
    name: str
    role: str
    description: Optional[str] = None
    color: str
    image_url: Optional[str] = None
    facebook_url: Optional[str] = None
    instagram_url: Optional[str] = None
    viber_url: Optional[str] = None
    display_order: int = 0

class CEOCreate(CEOBase):
    pass

class CEOUpdate(BaseModel):
    name: Optional[str] = None
    role: Optional[str] = None
    description: Optional[str] = None
    color: Optional[str] = None
    image_url: Optional[str] = None
    facebook_url: Optional[str] = None
    instagram_url: Optional[str] = None
    viber_url: Optional[str] = None
    display_order: Optional[int] = None

class CEO(CEOBase):
    id: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Supporter schemas
class SupporterBase(BaseModel):
    name: str
    title: str
    color: str
    icon: str = "school"
    image_url: Optional[str] = None
    description: Optional[str] = None
    display_order: int = 0

class SupporterCreate(SupporterBase):
    pass

class SupporterUpdate(BaseModel):
    name: Optional[str] = None
    title: Optional[str] = None
    color: Optional[str] = None
    icon: Optional[str] = None
    image_url: Optional[str] = None
    description: Optional[str] = None
    display_order: Optional[int] = None

class Supporter(SupporterBase):
    id: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Test category schemas
class TestBase(BaseModel):
    name: str
    description: Optional[str] = None
    image_url: Optional[str] = None

class TestCreate(TestBase):
    pass

class Test(TestBase):
    id: str
    created_at: datetime

    class Config:
        from_attributes = True

# Specific test category schemas
class HaematologyTestCreate(TestCreate):
    pass

class HaematologyTest(Test):
    pass

class SerologyTestCreate(TestCreate):
    pass

class SerologyTest(Test):
    pass

class BiochemistryTestCreate(TestCreate):
    pass

class BiochemistryTest(Test):
    pass

class BacteriologyTestCreate(TestCreate):
    pass

class BacteriologyTest(Test):
    pass

class OtherTestCreate(TestCreate):
    pass

class OtherTestModel(Test):
    pass

# Common response schemas
class PaginatedResponse(BaseModel):
    items: List[dict]
    total: int
    page: int
    size: int
    pages: int

class Token(BaseModel):
    access_token: str
    refresh_token: Optional[str] = None
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class RefreshTokenRequest(BaseModel):
    refresh_token: str