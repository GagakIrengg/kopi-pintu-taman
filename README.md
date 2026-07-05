# ☕ Kopi Pintu Taman — Sistem Rekomendasi Produk Unggulan

Sistem terintegrasi untuk operasional dan rekomendasi menu **Cafe Kopi Pintu Taman**, terdiri dari aplikasi POS mobile, web menu berbasis QR, dan modul analisis sentimen + SAW.

> Skripsi — Teknik Informatika, Universitas Tarumanagara  
> **Noel** · NIM 535210103  
> Pembimbing: Lely Hiryanto, S.T., M.Sc., Ph.D. & Novario Jaya Perdana, S.Kom., M.T.

---

## 🌐 Demo

| Komponen | URL |
|----------|-----|
| Web Menu | https://menu-kpt.up.railway.app |
| Backend API | https://menu-kpt.up.railway.app/docs |

```
kopi-pintu-taman/
│
├── pos-app/                  # Aplikasi POS mobile (Flutter)
│   ├── lib/
│   ├── assets/
│   ├── android/
│   ├── pubspec.yaml
│   └── ...
│
├── sentiment-model/          # Script IndoBERT + SAW
│   ├── saw_recommend.py      # ⭐ Script utama rekomendasi
│   ├── TrainIndobert.py      # Training model IndoBERT
│   ├── evaluate_model.py     # Evaluasi performa model
│   ├── sentiment_analysis.py # Analisis sentimen
│   ├── preprocess.py         # Preprocessing dataset
│   └── Cleaning.py           # Cleaning data ulasan
│
├── assets/                   # Asset gambar web menu
├── index.html                # Web menu (frontend)
├── script.js                 # Logic frontend
├── style.css                 # Styling web menu
├── main.py                   # Backend FastAPI
├── requirements.txt          # Python dependencies
└── Procfile                  # Konfigurasi Railway deployment
```

## 🛠 Tech Stack

| Komponen | Teknologi |
|----------|-----------|
| POS Mobile | Flutter, Dart, SQLite |
| Backend | Python, FastAPI |
| Frontend Web | HTML, CSS, JavaScript |
| Analisis Sentimen | IndoBERT (indobenchmark/indobert-base-p1) |
| Rekomendasi | Simple Additive Weighting (SAW) |
| Database | SQLite (POS lokal), Supabase (cloud) |
| Deployment | Railway |

---

## 🚀 Cara Menjalankan

### 1. Web Menu & Backend (Lokal)

```bash
git clone https://github.com/GagakIrengg/kopi-pintu-taman.git
cd kopi-pintu-taman
pip install -r requirements.txt
DATABASE_URL=your_supabase_connection_string
uvicorn main:app --reload
```

### 2. Aplikasi POS Mobile

```bash
cd pos-app
flutter pub get
flutter run
```

### 3. Modul Rekomendasi (SAW + IndoBERT)

```bash
cd sentiment-model
python saw_recommend.py
```

---

## 📊 Hasil Pengujian

### Analisis Sentimen (IndoBERT)

| Skenario | Dataset | Accuracy | F1 Netral |
|----------|---------|----------|-----------|
| Baseline | 1.205 data | 94,19% | 0,17 |
| Relabeling | 1.369 data | 90,51% | 0,36 |

### Rekomendasi SAW (Skenario 3)

| Peringkat | Menu | Nilai SAW |
|-----------|------|-----------|
| 🥇 1 | Roasted Almond Latte | 0,9348 |
| 🥈 2 | Kopi Creamy Aren | 0,8939 |
| 🥉 3 | Kopi Pintu Taman | 0,8708 |

### User Acceptance Testing

| Sistem | Responden | Skor | Kategori |
|--------|-----------|------|----------|
| Aplikasi POS | 4 | 89,29% | Sangat Layak |
| Web Menu | 23 | 92,37% | Sangat Layak |

---

## 📝 Catatan

- Folder model weights (`sentiment_model/`, `sentiment_model2/`) tidak diupload karena ukuran terlalu besar.
- Data transaksi real (`.db`) tidak diupload karena bersifat sensitif.

---

## 📬 Kontak

**Noel** · noel852003@gmail.com
GitHub: [@GagakIrengg](https://github.com/GagakIrengg)
