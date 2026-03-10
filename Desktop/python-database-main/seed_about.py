#!/usr/bin/env python3
"""
Seed the database with CEOs and Supporters for the About page.

Usage:
    python seed_about.py
"""

import uuid
from database import SessionLocal, engine
from models import Base, CEO, Supporter


CEOS = [
    {
        "name": "شادمان عثمان",
        "role": "بەڕێوبەر،گەشەپێدەر،دیزانکردنی فەرهەنگ",
        "description": "خوێندکاری کۆلێجی پزیشکی ڤیترنەری زانکۆی سلێمانی",
        "color": "#4A6FA5",
        "image_url": None,
        "facebook_url": "https://www.facebook.com/shadman.osman.2025",
        "instagram_url": "https://www.instagram.com/shadman_osman1/",
        "viber_url": "tel:+9647824961601",
        "display_order": 1,
    },
    {
        "name": "هاڕوون موبارەک",
        "role": "بەڕێوبەر،نوسەر،ڕێکخستن و کۆکردنەوەی زانیارییەکان",
        "description": "خویندکاری کۆلێژی پزیشکی ڤێترنەری زانکۆی سلێمانی",
        "color": "#4A6FA5",
        "image_url": None,
        "facebook_url": "https://www.facebook.com/harun.mubark.2025",
        "instagram_url": "https://www.instagram.com/harun_mubark/",
        "viber_url": "tel:+9647734402627",
        "display_order": 2,
    },
]

SUPPORTERS = [
    {
        "name": "پرۆفیسۆری یاریدەدەر د. نادیە عەبدالکریم صالح",
        "title": "پرۆفیسۆری یاریدەدەر و مامۆستای زانکۆ و ڕاگری کۆلێژی پزیشکی ڤێتیرنەری",
        "color": "#4A6FA5",
        "icon": "school",
        "image_url": None,
        "display_order": 1,
    },
    {
        "name": "پرۆفیسۆر د. فەرەیدوون عبدالستار",
        "title": "پرۆفیسۆر و مامۆستای زانکۆ و ڕاگری پێشووی کۆلیژی پزیشکی ڤێتیرنەری",
        "color": "#4A6FA5",
        "icon": "school",
        "image_url": None,
        "display_order": 2,
    },
    {
        "name": "د. پاڤێڵ عمر",
        "title": "پزیشکی ڤێتیرنەری و مامۆستای زانکۆی سلێمانی",
        "color": "#4A6FA5",
        "icon": "medical_services",
        "image_url": None,
        "display_order": 3,
    },
    {
        "name": "ئالان جوامێر",
        "title": "خوێندکاری کۆلێژی پزیشکی ڤێتیرنەری زانکۆی سلێمانی",
        "description": "نوسەری بەشی کەرەستە پزیشکیەکان",
        "color": "#4A6FA5",
        "icon": "medical_services",
        "image_url": None,
        "display_order": 4,
    },
]


def seed():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    try:
        # ── CEOs ──────────────────────────────────────────────────────────────
        existing_ceos = db.query(CEO).count()
        if existing_ceos > 0:
            print(f"⚠️  Skipping CEOs — {existing_ceos} record(s) already exist.")
        else:
            for data in CEOS:
                db.add(CEO(id=str(uuid.uuid4()), **data))
            db.commit()
            print(f"✅ Inserted {len(CEOS)} CEO(s).")

        # ── Supporters ────────────────────────────────────────────────────────
        existing_supporters = db.query(Supporter).count()
        if existing_supporters > 0:
            print(f"⚠️  Skipping Supporters — {existing_supporters} record(s) already exist.")
        else:
            for data in SUPPORTERS:
                db.add(Supporter(id=str(uuid.uuid4()), **data))
            db.commit()
            print(f"✅ Inserted {len(SUPPORTERS)} Supporter(s).")

        print("\n🎉 Done! About page data is ready.")

    except Exception as e:
        print(f"❌ Error: {e}")
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    seed()
