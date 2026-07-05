import pandas as pd
import numpy as np
import torch

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.utils.class_weight import compute_class_weight
from sklearn.metrics import accuracy_score, precision_recall_fscore_support
from sklearn.metrics import classification_report


from transformers import (
    AutoTokenizer,
    AutoModelForSequenceClassification,
    Trainer,
    TrainingArguments
)

from torch.utils.data import Dataset

# =========================
# LOAD DATASET
# =========================
print("📥 Loading dataset...")
df = pd.read_csv("dataset_relabel_clean.csv")

print("Dataset shape:", df.shape)

texts = df["clean_text"].astype(str).tolist()
labels = df["predicted_sentiment"].astype(str).tolist()

# =========================
# ENCODE LABEL
# =========================
label_encoder = LabelEncoder()
encoded_labels = label_encoder.fit_transform(labels)

print("\nLabel Mapping:")
for i, label in enumerate(label_encoder.classes_):
    print(f"{label} = {i}")

# =========================
# CLASS WEIGHT (IMPORTANT 🔥)
# =========================
class_weights = compute_class_weight(
    class_weight='balanced',
    classes=np.unique(encoded_labels),
    y=encoded_labels
)

class_weights = torch.tensor(class_weights, dtype=torch.float)

print("\nClass Weights:", class_weights)

# =========================
# TRAIN TEST SPLIT (STRATIFIED)
# =========================
train_texts, test_texts, train_labels, test_labels = train_test_split(
    texts,
    encoded_labels,
    test_size=0.2,
    stratify=encoded_labels,
    random_state=42
)

print("\nTrain size:", len(train_texts))
print("Test size:", len(test_texts))

# =========================
# TOKENIZER
# =========================
model_name = "indobenchmark/indobert-base-p1"
tokenizer = AutoTokenizer.from_pretrained(model_name)

train_encodings = tokenizer(
    train_texts,
    truncation=True,
    padding=True,
    max_length=128
)

test_encodings = tokenizer(
    test_texts,
    truncation=True,
    padding=True,
    max_length=128
)

# =========================
# DATASET CLASS
# =========================
class ReviewDataset(Dataset):
    def __init__(self, encodings, labels):
        self.encodings = encodings
        self.labels = labels

    def __getitem__(self, idx):
        item = {key: torch.tensor(val[idx]) for key, val in self.encodings.items()}
        item["labels"] = torch.tensor(self.labels[idx])
        return item

    def __len__(self):
        return len(self.labels)

train_dataset = ReviewDataset(train_encodings, train_labels)
test_dataset = ReviewDataset(test_encodings, test_labels)

# =========================
# MODEL
# =========================
print("\n📦 Loading model...")
model = AutoModelForSequenceClassification.from_pretrained(
    model_name,
    num_labels=len(label_encoder.classes_)
)

# 🔥 APPLY CLASS WEIGHT (BALANCED LOSS)
model.classifier.loss_fct = torch.nn.CrossEntropyLoss(weight=class_weights)

# =========================
# METRICS
# =========================
def compute_metrics(pred):
    labels = pred.label_ids
    preds = pred.predictions.argmax(-1)

    precision, recall, f1, _ = precision_recall_fscore_support(
        labels,
        preds,
        average='weighted'
    )

    acc = accuracy_score(labels, preds)

    return {
        "accuracy": acc,
        "f1": f1,
        "precision": precision,
        "recall": recall
    }

# =========================
# TRAINING ARGUMENTS
# =========================
training_args = TrainingArguments(
    output_dir="./results",
    evaluation_strategy="epoch",
    save_strategy="epoch",
    logging_strategy="steps",
    logging_steps=10,

    per_device_train_batch_size=8,
    per_device_eval_batch_size=8,

    num_train_epochs=3, #c0ba tingkatin, ubah learning rate, perbedaan split training testing

    report_to="none"
)

# =========================
# TRAINER
# =========================
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=train_dataset,
    eval_dataset=test_dataset,
    compute_metrics=compute_metrics,
)

# =========================
# TRAINING
# =========================
print("\n🚀 START TRAINING...")
trainer.train()

# =========================
# EVALUATION
# =========================
print("\n📊 EVALUATION...")
results = trainer.evaluate()

print("\n=== FINAL RESULTS ===")
print(results)

# Tambah ini SEBELUM model.save_pretrained
predictions = trainer.predict(test_dataset)
preds = predictions.predictions.argmax(-1)
print("\n=== CLASSIFICATION REPORT ===")
print(classification_report(test_labels, preds, target_names=label_encoder.classes_, zero_division=0))
# =========================
# SAVE MODEL
# =========================
model.save_pretrained("./sentiment_model2")
tokenizer.save_pretrained("./sentiment_model2")

print("\n✅ Model saved to ./sentiment_model2")