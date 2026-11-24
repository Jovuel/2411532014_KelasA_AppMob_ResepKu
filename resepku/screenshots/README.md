# Folder Screenshots — Modul 8

Isi folder ini dengan 11 screenshot yang diambil dari aplikasi ResepKu yang berjalan di **emulator Android / HP** (bukan web). Setiap screenshot **WAJIB** memperlihatkan footer NIM/nama (`2411532014 - Jovantri Immanuel Gulo`).

## Daftar Screenshot yang Dibutuhkan

| No | Nama File | Cara Mengambil |
|---|---|---|
| 1 | `cp1_home.png` | Buka aplikasi → tunggu 50 resep tampil (indikator loading lalu daftar). Tunjukkan resep yang bukan 6 dummy. |
| 2 | `cp1_detail.png` | Tekan salah satu resep → scroll ke bawah hingga foto, porsi, bahan, dan bagian "Langkah". |
| 3 | `cp2_error.png` | Aktifkan Mode Pesawat → hot restart (R) → ErrorView (wifi_off + tombol "Coba lagi"). |
| 4 | `cp2_refresh.png` | Matikan Mode Pesawat → tekan "Coba lagi" → lalu tarik daftar ke bawah (pull-to-refresh). |
| 5 | `cp3_form.png` | Tekan `+` → isi Rendang / Indonesian / 180 → Simpan → SnackBar id. |
| 6 | `cp3_validasi.png` | Tekan `+` → Simpan dengan form kosong → "Wajib diisi". |
| 7 | `latihan1_hasil.png` | Ikon kaca pembesar → ketik "pasta" → Enter → hasil. |
| 8 | `latihan1_kosong.png` | Ikon kaca pembesar → ketik kata kunci acak → Enter → "Tidak ada resep yang cocok." |
| 9 | `latihan1_error.png` | Mode Pesawat ON → cari → ErrorView. |
| 10 | `latihan2_ubah.png` | Detail resep → PopupMenu "Ubah nama" → AlertDialog → Simpan → SnackBar. |
| 11 | `latihan2_hapus.png` | Detail resep → PopupMenu "Hapus" → konfirmasi → SnackBar + halaman tertutup. |

## Perintah Menjalankan

```bash
flutter run -d <device_id>
```

(lihat `flutter devices` untuk ID emulator/HP)

## Verifikasi (sudah lolos)

- `flutter analyze lib` → No issues found!
- `flutter test test/recipe_service_test.dart` → All tests passed!