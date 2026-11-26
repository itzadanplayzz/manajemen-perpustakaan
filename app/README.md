# Aplikasi Perpustakaan (Flutter)

Klien Android untuk API **Manajemen Perpustakaan**. Aplikasi ini memakai API yang sama dengan versi web (`web/api.php`), sehingga data buku, anggota, dan transaksi tetap sinkron.

## Fitur

- Tab **Katalog** — daftar buku, pencarian ID/judul, filter Tersedia/Habis.
- Tab **Sirkulasi** — pinjam, kembali, dan tambah buku.
- Tab **Riwayat** — catatan transaksi peminjaman dan pengembalian.
- Mode gelap/terang dan muat data contoh.

## Menjalankan

```bash
flutter pub get

flutter run --dart-define=API_BASE_URL=http://<IP-LAPTOP>/manajemen_perpustakaan/api.php
```

Build APK:

```bash
flutter build apk --release --dart-define=API_BASE_URL=http://<IP-LAPTOP>/manajemen_perpustakaan/api.php
```

Nilai default `API_BASE_URL` ada di `lib/perpustakaan.dart` (`http://192.168.3.144/manajemen_perpustakaan/api.php`). Ganti dengan IP komputer yang menjalankan XAMPP; HP dan laptop harus satu jaringan.

## Struktur

```text
lib/
├── main.dart           # UI, navigasi, dan state
└── perpustakaan.dart   # Model domain (Buku, Anggota, Peminjaman) + klien API
test/
└── widget_test.dart
```

## Pengujian

```bash
flutter test
```

Dokumentasi lengkap proyek ada di [README utama](../README.md).
