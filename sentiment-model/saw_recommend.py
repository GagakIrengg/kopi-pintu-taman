"""
SAW Recommendation Script — Kopi Pintu Taman
=============================================
Jalankan MANUAL (batch, mis. tiap 2 minggu):

    python saw_recommend.py

Alur:
  1. Baca ulasan dari PostgreSQL (tabel reviews)
  2. IndoBERT (./sentiment_model) -> skor sentimen tiap ulasan
  3. Agregasi skor sentimen per menu
  4. Baca data penjualan dari SQLite POS (kpt_pos.db) ← UPDATED
  5. Hitung SAW (normalisasi min-max + bobot) -> ranking
  6. Tulis hasil ke tabel recommendations di PostgreSQL

Sebelum jalankan, pull dulu file DB dari emulator:
    adb pull /data/data/<package_name>/app_flutter/kpt_pos.db .
  (ganti <package_name> dengan applicationId di android/app/build.gradle)

Wajib di-set environment variable DATABASE_URL (sama dengan yang dipakai
FastAPI). Contoh (Windows PowerShell):
    $env:DATABASE_URL="postgresql://user:pass@localhost:5432/namadb"
"""

import os
import sqlite3
import sys
from datetime import datetime

import psycopg2
import torch
import torch.nn.functional as F
from transformers import AutoTokenizer, AutoModelForSequenceClassification

# ============================================================
# KONFIGURASI — sesuaikan kalau perlu
# ============================================================
MODEL_DIR    = "./sentiment_model2"   # hasil save_pretrained training kamu
SQLITE_DB    = "kpt_pos.db"          # pull dari emulator dulu (lihat docstring)
DATABASE_URL = os.getenv("DATABASE_URL")

# Bobot SAW (sesuai proposal skripsi: 60% sentimen, 40% penjualan)
W_SENTIMENT = 0.60
W_SALES     = 0.40

# Berapa banyak menu teratas yang ditandai "recommended" untuk web
TOP_N = 3

# ============================================================
# 1. LOAD MODEL INDOBERT
# ============================================================
print("📦 Loading IndoBERT dari", MODEL_DIR, "...")
tokenizer = AutoTokenizer.from_pretrained(MODEL_DIR)
model     = AutoModelForSequenceClassification.from_pretrained(MODEL_DIR)
model.eval()

num_labels = model.config.num_labels
print(f"   num_labels = {num_labels}")
print(f"   id2label   = {model.config.id2label}")
print()
print("⚠️  PENTING — verifikasi mapping label di atas.")
print("   Script ini mengasumsikan ada kelas 'positif' & 'negatif'.")
print("   Kalau label kamu beda (mis. 'positive'/angka), sesuaikan")
print("   variabel POSITIVE_LABELS / NEGATIVE_LABELS di bawah.\n")

# Set label mana yang dianggap positif / negatif (huruf kecil).
# LabelEncoder mengurutkan alfabetis: negatif=0, netral=1, positif=2
POSITIVE_LABELS = {"positif", "positive", "pos", "2"}
NEGATIVE_LABELS = {"negatif", "negative", "neg", "0"}


def label_name(idx: int) -> str:
    raw = model.config.id2label.get(idx, str(idx))
    return str(raw).lower()


def sentiment_score(text: str) -> float:
    """
    Kembalikan skor sentimen 0..1 untuk 1 ulasan.
    Skor = probabilitas kelas positif (softmax).
    """
    if not text or not text.strip():
        return 0.5  # netral default kalau ulasan kosong

    enc = tokenizer(
        text,
        truncation=True,
        padding=True,
        max_length=128,
        return_tensors="pt",
    )
    with torch.no_grad():
        logits = model(**enc).logits
        probs  = F.softmax(logits, dim=-1)[0]

    pos_idx = None
    for i in range(num_labels):
        if label_name(i) in POSITIVE_LABELS:
            pos_idx = i
            break

    if pos_idx is not None:
        return float(probs[pos_idx].item())

    # fallback: index terakhir = positif (alfabetis negatif<netral<positif)
    return float(probs[-1].item())


# ============================================================
# 2. BACA ULASAN DARI POSTGRESQL
# ============================================================
if not DATABASE_URL:
    print("❌ DATABASE_URL belum di-set. Set dulu environment variable-nya.")
    sys.exit(1)

print("🗄️  Connect ke PostgreSQL...")
conn = psycopg2.connect(DATABASE_URL)
cur  = conn.cursor()

cur.execute("SELECT menu_name, rating, review_text FROM reviews")
rows = cur.fetchall()
print(f"   {len(rows)} ulasan ditemukan.\n")

# ============================================================
# 3. AGREGASI SKOR SENTIMEN PER MENU
# ============================================================
print("🧠 Menjalankan IndoBERT ke tiap ulasan...")
sent_sum: dict[str, float] = {}
sent_cnt: dict[str, int]   = {}

for i, (menu_name, rating, review_text) in enumerate(rows, 1):
    s = sentiment_score(review_text or "")
    sent_sum[menu_name] = sent_sum.get(menu_name, 0.0) + s
    sent_cnt[menu_name] = sent_cnt.get(menu_name, 0) + 1
    if i % 25 == 0:
        print(f"   {i}/{len(rows)} ulasan diproses...")

# rata-rata skor sentimen per menu (0..1)
sentiment_avg = {
    m: sent_sum[m] / sent_cnt[m] for m in sent_sum
}
print(f"   Selesai. {len(sentiment_avg)} menu punya ulasan.\n")

# ============================================================
# 4. BACA DATA PENJUALAN DARI SQLITE POS  ← UPDATED
# ============================================================
# Data diambil langsung dari database POS Flutter (kpt_pos.db).
# Pull file DB dari emulator dulu:
#   adb pull /data/data/<package_name>/app_flutter/kpt_pos.db .
#
# Query hanya mengambil transaksi paid (voided dikecualikan)
# dan menu_item_id != 'custom' (menu custom dikecualikan dari SAW).
# ============================================================
if not os.path.exists(SQLITE_DB):
    print(f"❌ {SQLITE_DB} tidak ditemukan di folder ini.")
    print("   Pull dulu dari emulator:")
    print("   adb pull /data/data/<package_name>/app_flutter/kpt_pos.db .")
    print("   (cek package_name di android/app/build.gradle → applicationId)")
    sys.exit(1)

print(f"📱 Baca data penjualan dari SQLite POS: {SQLITE_DB}")
sqlite_conn = sqlite3.connect(SQLITE_DB)
sqlite_cur  = sqlite_conn.execute("""
    SELECT  ti.menu_name,
            SUM(ti.quantity) AS qty_terjual
    FROM    transaction_items ti
    JOIN    transactions t ON t.id = ti.transaction_id
    WHERE   t.status          = 'paid'
      AND   ti.menu_item_id  != 'custom'
    GROUP BY ti.menu_name
    ORDER BY qty_terjual DESC
""")
rows_sales = sqlite_cur.fetchall()
sqlite_conn.close()

sales: dict[str, float] = {}
for menu_name, qty in rows_sales:
    if menu_name:
        sales[menu_name.strip()] = float(qty)

print(f"   {len(sales)} menu punya data penjualan dari POS.\n")
print("   Rincian penjualan per menu:")
for m, q in sorted(sales.items(), key=lambda x: -x[1]):
    print(f"   {m:<28} {int(q):>4} pcs")
print()

# ============================================================
# 5. HITUNG SAW
# ============================================================
# Kandidat = menu yang punya KEDUA data (sentimen & penjualan).
candidates = sorted(set(sentiment_avg) & set(sales))

if not candidates:
    print("❌ Tidak ada menu yang punya ulasan SEKALIGUS data penjualan.")
    print("   Pastikan nama menu di tabel reviews PostgreSQL sama persis")
    print("   dengan nama menu di transaction_items SQLite.")
    print()
    print("   Menu di SQLite  :", sorted(sales.keys()))
    print("   Menu di reviews :", sorted(sentiment_avg.keys()))
    sys.exit(1)

print(f"🧮 SAW untuk {len(candidates)} menu kandidat...")

sent_vals = [sentiment_avg[m] for m in candidates]
sale_vals = [sales[m]         for m in candidates]


def norm_minmax(vals):
    lo, hi = min(vals), max(vals)
    if hi == lo:
        return [1.0 for _ in vals]   # semua sama -> nilai penuh
    return [(v - lo) / (hi - lo) for v in vals]


sent_n = norm_minmax(sent_vals)
sale_n = norm_minmax(sale_vals)

results = []
for i, m in enumerate(candidates):
    v = W_SENTIMENT * sent_n[i] + W_SALES * sale_n[i]
    results.append({
        "menu_name"    : m,
        "sentiment_avg": round(sentiment_avg[m], 6),
        "sales_qty"    : sales[m],
        "saw_score"    : round(v, 6),
    })

results.sort(key=lambda x: x["saw_score"], reverse=True)

print("\n=== HASIL RANKING SAW ===")
for rank, r in enumerate(results, 1):
    tag = "  <- RECOMMENDED" if rank <= TOP_N else ""
    print(f"{rank:2d}. {r['menu_name']:<28} "
          f"SAW={r['saw_score']:.4f} "
          f"(sentimen={r['sentiment_avg']:.3f}, "
          f"jual={r['sales_qty']:.0f}){tag}")
print()

# ---- RINCIAN PRESISI TINGGI (untuk pelaporan skripsi) ----
print("=== RINCIAN PRESISI TINGGI (skor sentimen sebenarnya) ===")
print(f"{'Menu':<28} {'Sentimen (presisi)':<22} "
      f"{'Penjualan':<10} {'Nilai SAW (presisi)'}")
for rank, r in enumerate(results, 1):
    m = r["menu_name"]
    print(f"{m:<28} {sentiment_avg[m]:<22.10f} "
          f"{sales[m]:<10.0f} {r['saw_score']:.10f}")
print()

print("=== NILAI TERNORMALISASI (min-max) ===")
print(f"{'Menu':<28} {'Sentimen_norm':<18} {'Penjualan_norm'}")
norm_map = {m: (sent_n[idx], sale_n[idx])
            for idx, m in enumerate(candidates)}
for rank, r in enumerate(results, 1):
    m = r["menu_name"]
    sn, sln = norm_map[m]
    print(f"{m:<28} {sn:<18.10f} {sln:.10f}")
print()

# ============================================================
# 6. TULIS HASIL KE POSTGRESQL (tabel recommendations)
# ============================================================
print("💾 Menyimpan hasil ke tabel recommendations...")
cur.execute("""
    CREATE TABLE IF NOT EXISTS recommendations (
        id            SERIAL PRIMARY KEY,
        rank          INTEGER NOT NULL,
        menu_name     TEXT    NOT NULL,
        sentiment_avg REAL,
        sales_qty     REAL,
        saw_score     REAL,
        is_recommended BOOLEAN DEFAULT FALSE,
        computed_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
""")
cur.execute("DELETE FROM recommendations")

for rank, r in enumerate(results, 1):
    cur.execute(
        """INSERT INTO recommendations
           (rank, menu_name, sentiment_avg, sales_qty, saw_score, is_recommended)
           VALUES (%s, %s, %s, %s, %s, %s)""",
        (rank, r["menu_name"], r["sentiment_avg"], r["sales_qty"],
         r["saw_score"], rank <= TOP_N),
    )

conn.commit()
cur.close()
conn.close()

print(f"✅ Selesai. {len(results)} menu tersimpan. "
      f"Top {TOP_N} ditandai recommended.")
print("   Web akan otomatis menampilkan lewat endpoint /api/recommendations.")