"""
Kopi Pintu Taman — FastAPI Backend
Run: python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel, Field
import psycopg2
import os
from datetime import datetime
from pathlib import Path

BASE_DIR = Path(__file__).parent
DATABASE_URL = os.getenv("DATABASE_URL")

# ========================
# DATABASE
# ========================
def get_db():
    conn = psycopg2.connect(DATABASE_URL)

    cursor = conn.cursor()

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS reviews (
            review_id SERIAL PRIMARY KEY,
            menu_name TEXT NOT NULL,
            rating INTEGER CHECK(rating BETWEEN 1 AND 5),
            review_text TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    conn.commit()
    cursor.close()

    return conn


# init DB
get_db().close()

# ========================
# APP INIT
# ========================
app = FastAPI(title="Kopi Pintu Taman API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ========================
# MODEL
# ========================
class ReviewIn(BaseModel):
    menu_name: str
    rating: int = Field(ge=1, le=5)
    review_text: str = ""


# ========================
# API ROUTES
# ========================

@app.post("/api/reviews")
def create_review(review: ReviewIn):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute(
        "INSERT INTO reviews (menu_name, rating, review_text) VALUES (%s, %s, %s)",
        (review.menu_name, review.rating, review.review_text),
    )

    conn.commit()

    cursor.close()
    conn.close()

    return {
        "status": "success",
        "message": "Review berhasil disimpan!"
    }


@app.get("/api/reviews")
def list_reviews():
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT review_id, menu_name, rating, review_text, created_at
        FROM reviews
        ORDER BY created_at DESC
    """)

    rows = cursor.fetchall()

    cursor.close()
    conn.close()

    return [
        {
            "review_id": r[0],
            "menu_name": r[1],
            "rating": r[2],
            "review_text": r[3],
            "created_at": r[4]
        }
        for r in rows
    ]

@app.get("/api/recommendations")
def list_recommendations():
    conn = get_db()
    cursor = conn.cursor()

    # Tabel recommendations dibuat oleh script saw_recommend.py.
    # Kalau belum pernah dijalankan, kembalikan list kosong (web fallback).
    try:
        cursor.execute("""
            SELECT rank, menu_name, sentiment_avg, sales_qty,
                   saw_score, is_recommended
            FROM recommendations
            ORDER BY rank ASC
        """)
        rows = cursor.fetchall()
    except Exception:
        conn.rollback()
        rows = []

    cursor.close()
    conn.close()

    return [
        {
            "rank": r[0],
            "menu_name": r[1],
            "sentiment_avg": r[2],
            "sales_qty": r[3],
            "saw_score": r[4],
            "is_recommended": r[5],
        }
        for r in rows
    ]

# ========================
# STATIC (FRONTEND)
# ========================

app.mount("/static", StaticFiles(directory=BASE_DIR), name="static")


@app.get("/")
def serve_index():
    return FileResponse(BASE_DIR / "index.html")