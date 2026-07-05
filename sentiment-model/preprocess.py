import pandas as pd
import re

# Load dataset
df = pd.read_excel("Dataset_Lengkap.xlsx")

# Function preprocessings
def preprocess_text(text):
    text = str(text).lower()

    # hapus URL
    text = re.sub(r'http\\S+|www\\S+', '', text)

    # hapus mention dan hashtag
    text = re.sub(r'[@#]\\w+', '', text)

    # hapus angka
    text = re.sub(r'\\d+', '', text)

    # hapus emoji dan simbol
    text = re.sub(r'[^a-zA-Z\\s]', ' ', text)

    # hapus spasi berlebih
    text = re.sub(r'\\s+', ' ', text).strip()

    return text

# Preprocessing kolom content
df["clean_text"] = df["content"].apply(preprocess_text)

# Hapus data kosong setelah preprocessing
df = df[df["clean_text"].str.strip() != ""]

# Cek distribusi sentiment
print("\\nDistribusi Sentiment:")
print(df["predicted_sentiment"].value_counts())

# Save ke CSV
df.to_csv("dataset_clean.csv", index=False)

print("\\nPreprocessing selesai!")
print("File saved: dataset_clean.csv")