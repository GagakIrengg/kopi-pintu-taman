"""
evaluate_model.py — Regenerasi SEMUA bukti Bab 4.2.3 TANPA training ulang
=========================================================================
Skrip ini MEMUAT model yang sudah kamu simpan (./sentiment_model) lalu
mengevaluasinya pada data uji yang SAMA PERSIS dengan saat training
(karena split pakai random_state=42 yang deterministik).

Output (semua otomatis tersimpan jadi file, siap tempel ke skripsi):
  1. metrics.txt            -> accuracy, precision, recall, f1
  2. confusion_matrix.png   -> heatmap confusion matrix (Gambar 4.x)
  3. distribusi_kelas.png   -> bar chart distribusi 1207 data (Gambar 4.x)
  4. classification_report.txt -> rincian per kelas
  5. tabel_metrik.txt       -> tabel siap salin ke Word

CARA PAKAI:
  1. Taruh skrip ini di folder yang sama dengan:
       - dataset_clean.csv         (dataset yang dipakai training)
       - folder ./sentiment_model  (model hasil save_pretrained)
  2. Install sekali (kalau belum):
       pip install torch transformers scikit-learn pandas matplotlib
  3. Jalankan:
       python evaluate_model.py
  4. Ambil file gambar & txt yang dihasilkan -> masukkan ke skripsi.

CATATAN PENTING:
  - Skrip ini TIDAK melatih ulang. Hanya inference -> cepat.
  - Angka yang dihasilkan adalah performa NYATA model kamu (jujur, bukan
    karangan) karena memakai model & data uji yang sama dengan training.
  - Kalau dataset_clean.csv atau ./sentiment_model tidak sama dengan saat
    training, hasilnya bisa berbeda. Pastikan keduanya yang asli.
"""

import pandas as pd
import numpy as np
import torch
import torch.nn.functional as F
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import (accuracy_score, precision_recall_fscore_support,
                             confusion_matrix, classification_report)
from transformers import AutoTokenizer, AutoModelForSequenceClassification

DATASET   = "dataset_relabel_clean.csv"   # ← nama file dataset relabeling lo
MODEL_DIR = "./sentiment_model2"    # ← folder model relabeling

# ============================================================
# 1. LOAD DATASET & RECREATE SPLIT (sama persis dgn training)
# ============================================================
print("Memuat dataset...")
df = pd.read_csv(DATASET)
texts = df["clean_text"].astype(str).tolist()
labels = df["predicted_sentiment"].astype(str).tolist()

label_encoder = LabelEncoder()
encoded_labels = label_encoder.fit_transform(labels)
class_names = list(label_encoder.classes_)
print("Kelas:", class_names, "(urut:", list(range(len(class_names))), ")")
print("Total data:", len(texts))

# Split IDENTIK dengan training: test_size=0.2, stratify, random_state=42
_, test_texts, _, test_labels = train_test_split(
    texts, encoded_labels, test_size=0.2,
    stratify=encoded_labels, random_state=42
)
print("Jumlah data uji:", len(test_texts))

# ============================================================
# 2. LOAD MODEL TERSIMPAN (TANPA TRAINING ULANG)
# ============================================================
print("\nMemuat model tersimpan dari", MODEL_DIR, "...")
tokenizer = AutoTokenizer.from_pretrained(MODEL_DIR)
model = AutoModelForSequenceClassification.from_pretrained(MODEL_DIR)
model.eval()

# ============================================================
# 3. PREDIKSI DATA UJI (inference, cepat)
# ============================================================
print("Memprediksi data uji...")
preds = []
batch = 16
for i in range(0, len(test_texts), batch):
    chunk = test_texts[i:i + batch]
    enc = tokenizer(chunk, truncation=True, padding=True,
                    max_length=128, return_tensors="pt")
    with torch.no_grad():
        logits = model(**enc).logits
    preds.extend(torch.argmax(logits, dim=-1).tolist())
    print(f"  {min(i + batch, len(test_texts))}/{len(test_texts)}")

y_true = np.array(test_labels)
y_pred = np.array(preds)

# ============================================================
# 4. HITUNG METRIK
# ============================================================
acc = accuracy_score(y_true, y_pred)
prec, rec, f1, _ = precision_recall_fscore_support(
    y_true, y_pred, average="weighted", zero_division=0)

with open("metrics.txt", "w") as f:
    f.write("=== HASIL EVALUASI MODEL INDOBERT (DATA UJI) ===\n")
    f.write(f"Jumlah data uji : {len(test_texts)}\n")
    f.write(f"Accuracy  : {acc:.4f}\n")
    f.write(f"Precision : {prec:.4f}\n")
    f.write(f"Recall    : {rec:.4f}\n")
    f.write(f"F1-Score  : {f1:.4f}\n")

# Tabel siap salin ke Word
with open("tabel_metrik.txt", "w") as f:
    f.write("Metrik\tNilai\n")
    f.write(f"Accuracy\t{acc:.4f}\n")
    f.write(f"Precision\t{prec:.4f}\n")
    f.write(f"Recall\t{rec:.4f}\n")
    f.write(f"F1-Score\t{f1:.4f}\n")

rep = classification_report(y_true, y_pred, target_names=class_names,
                            zero_division=0)
with open("classification_report.txt", "w") as f:
    f.write(rep)

print("\n=== METRIK ===")
print(f"Accuracy={acc:.4f} Precision={prec:.4f} "
      f"Recall={rec:.4f} F1={f1:.4f}")

# ============================================================
# 5. CONFUSION MATRIX (heatmap -> Gambar 4.x)
# ============================================================
cm = confusion_matrix(y_true, y_pred)
plt.figure(figsize=(6, 5))
plt.imshow(cm, cmap="Blues")
plt.colorbar()
plt.xticks(range(len(class_names)), class_names, rotation=45, ha="right")
plt.yticks(range(len(class_names)), class_names)
# tulis angka di tiap sel
thresh = cm.max() / 2.0
for i in range(cm.shape[0]):
    for j in range(cm.shape[1]):
        plt.text(j, i, str(cm[i, j]), ha="center", va="center",
                 color="white" if cm[i, j] > thresh else "black")
plt.xlabel("Prediksi")
plt.ylabel("Aktual")
plt.title("Confusion Matrix Model IndoBERT")
plt.tight_layout()
plt.savefig("confusion_matrix.png", dpi=200)
plt.close()
print("Tersimpan: confusion_matrix.png")

# Confusion matrix versi tabel (siap salin Word)
with open("confusion_matrix_tabel.txt", "w") as f:
    header = "Aktual\\Prediksi\t" + "\t".join(class_names) + "\n"
    f.write(header)
    for i, name in enumerate(class_names):
        row = name + "\t" + "\t".join(str(x) for x in cm[i]) + "\n"
        f.write(row)

# ============================================================
# 6. DISTRIBUSI KELAS (bar chart -> Gambar 4.x)
# ============================================================
unique, counts = np.unique(encoded_labels, return_counts=True)
plt.figure(figsize=(6, 4))
bars = plt.bar([class_names[u] for u in unique], counts,
               color=["#c0392b", "#7f8c8d", "#27ae60"][:len(unique)])
for b, c in zip(bars, counts):
    plt.text(b.get_x() + b.get_width() / 2, c, str(c),
             ha="center", va="bottom")
plt.xlabel("Kelas Sentimen")
plt.ylabel("Jumlah Data")
plt.title(f"Distribusi Kelas Dataset (Total {len(texts)} Data)")
plt.tight_layout()
plt.savefig("distribusi_kelas.png", dpi=200)
plt.close()
print("Tersimpan: distribusi_kelas.png")

print("\nSELESAI. File bukti untuk Bab 4.2.3:")
print("  metrics.txt, tabel_metrik.txt, classification_report.txt")
print("  confusion_matrix.png, confusion_matrix_tabel.txt")
print("  distribusi_kelas.png")