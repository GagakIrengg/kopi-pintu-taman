import pandas as pd

# =========================
# LOAD FILE
# =========================
df1 = pd.read_excel("pintu_taman.xlsx")
df2 = pd.read_excel("teman_sejawat.xlsx")
df3 = pd.read_excel("kopilikasi.xlsx")
df4 = pd.read_excel("KOZI.xlsx")
df5 = pd.read_excel("kaizen_bekasi.xlsx")


# =========================
# CLEAN COLUMN NAME
# =========================
df1.columns = df1.columns.str.strip()
df2.columns = df2.columns.str.strip()
df3.columns = df3.columns.str.strip()
df4.columns = df4.columns.str.strip()
df5.columns = df5.columns.str.strip()


# =========================
# FUNCTION NORMALISASI AMAN
# =========================
def fix_df(df, cafe_name):

    # pastikan kolom minimal ada
    required_cols = ["reviewer", "stars", "content"]

    # cek kolom yang tersedia
    for col in required_cols:
        if col not in df.columns:
            raise ValueError(f"Kolom {col} tidak ditemukan di dataset!")

    df = df[required_cols].copy()

    # isi cafe_name dari file
    df["cafe_name"] = cafe_name

    # predicted sentimen kosong dulu
    df["predicted sentimen"] = None

    return df[["reviewer", "cafe_name", "content", "stars", "predicted sentimen"]]


# =========================
# FILE 1 (JUGA DIAMANKAN)
# =========================
if "cafe_name" in df1.columns:
    df1 = df1[["reviewer", "cafe_name", "content", "stars"]].copy()
else:
    df1 = df1[["reviewer", "content", "stars"]].copy()
    df1["cafe_name"] = "pintu_taman"

df1["predicted sentimen"] = None


# =========================
# FILE LAIN
# =========================
df2 = fix_df(df2, "teman_sejawat")
df3 = fix_df(df3, "kopilikasi")
df4 = fix_df(df4, "kozi")
df5 = fix_df(df5, "kaizen_bekasi")




# =========================
# GABUNG DATA
# =========================
df_final = pd.concat([df1, df2, df3, df4, df5], ignore_index=True)


# =========================
# CLEANING
# =========================
df_final = df_final.dropna(subset=["content"])
df_final = df_final[df_final["content"].astype(str).str.strip() != ""]
df_final = df_final.drop_duplicates(subset=["content"])
df_final = df_final.reset_index(drop=True)


# =========================
# SAVE
# =========================
df_final.to_excel("dataset_gabungan.xlsx", index=False)

print("SUKSES! Total data:", len(df_final))