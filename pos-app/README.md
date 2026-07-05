# KPT POS - Cafe Kopi Pintu Taman

Aplikasi Point of Sale (POS) Flutter untuk coffee shop kecil **Kopi Pintu Taman**.
Dirancang untuk **tablet Android landscape**, **offline-first** (SQLite), dengan
arsitektur scalable yang siap dihubungkan ke **Supabase** di tahap berikutnya.

> Foundation project ini dibuat oleh Lovable agar Anda lanjutkan di VSCode.

## Fitur

- 🔐 Login kasir (mock, siap diganti Supabase Auth)
- 💵 Opening cash (input kas awal sebelum mulai shift)
- ☕ POS utama (tablet landscape, kategori, search, cart, hot/iced popup, item notes, transaction notes, add-ons)
- ⏸ Hold / Open Bill (simpan transaksi sementara, buka kembali)
- 💳 Pembayaran Cash (shortcut nominal 20k/50k/100k + manual) & QRIS
- 🧾 Digital receipt sederhana
- 📦 Inventory (nama, stok, min stock, status)
- 📊 Sales Report + Order History (filter tanggal, detail per transaksi)
- 📡 Indikator status: Online / Offline / Pending Sync
- 🗃 Offline-first dengan SQLite (sqflite)
- 🧠 Sentiment / rekomendasi AI **TIDAK** ada di app ini (dibangun terpisah)

## Tech Stack

| Layer | Pilihan |
|-------|---------|
| Framework | Flutter 3.19+ |
| State Mgmt | Riverpod 2 (+ codegen) |
| Routing | go_router |
| Local DB | sqflite (SQLite) |
| Models | freezed + json_serializable |
| Backend (next) | Supabase |

## Cara Menjalankan

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d <tablet_android_id>
```

> Disarankan emulator/tablet **landscape**, resolusi minimal 1280x800.

Login default (mock):
- username: `kasir`
- password: `kasir123`

## Struktur Folder

```
lib/
├─ main.dart
├─ app.dart
├─ core/
│  ├─ theme/            # Warm coffee theme (brown, cream)
│  ├─ constants/        # App-wide constants
│  ├─ router/           # go_router config
│  └─ utils/            # Formatter (rupiah, tanggal)
├─ data/
│  ├─ models/           # MenuItem, CartItem, Transaction, dst (freezed)
│  ├─ database/         # SQLite helper + schema
│  ├─ datasources/      # *_local_datasource.dart (siap ditambah remote)
│  └─ repositories/     # Repository interface + impl
├─ services/            # connectivity_service, sync_service (stub)
├─ providers/           # Riverpod providers global
├─ shared/widgets/      # Widgets reusable
└─ features/
   ├─ auth/
   ├─ opening_cash/
   ├─ pos/
   ├─ inventory/
   ├─ sales_report/
   └─ settings/
```

## Roadmap Integrasi Supabase

1. Buat project Supabase + tabel: `menu_items`, `transactions`, `transaction_items`,
   `inventory`, `held_bills`, `cash_sessions`, `users`.
2. Tambah `supabase_flutter` ke `pubspec.yaml`.
3. Implement `*RemoteDatasource` di `data/datasources/` (mirror dari local datasource).
4. Modifikasi repository untuk pola **offline-first**:
   - Tulis ke SQLite dulu (`pending_sync = 1`).
   - `SyncService` push ke Supabase saat online, lalu set `pending_sync = 0`.
5. Ganti `MockAuthRepository` dengan `SupabaseAuthRepository`.

Semua interface sudah diisolasi sehingga perubahan minimal.
