# Laporan Modul 8 — HTTP Request & Integrasi API (ResepKu)

**Projek:** ResepKu (Flutter)  
**Lokasi:** `resepku/`

---

## Verifikasi Kode

| Perintah | Hasil |
|---|---|
| `flutter pub get` | Berhasil |
| `flutter analyze lib` | **No issues found!** |
| `flutter test test/recipe_service_test.dart` | **All tests passed!** (4 tes) |

---

## 1. Tabel Langkah A.1

Diambil dari `https://dummyjson.com/recipes?limit=2`.

| Pertanyaan | Jawaban |
|---|---|
| Nilai total | 50 |
| Key yang berisi daftar resep | `recipes` |
| Tipe nilai rating pada resep pertama | **double** (nilai 4.6, JSON parser Dart mengembalikan `double` untuk `4.6`) |
| Tiga key resep yang belum ada di model Recipe Modul 7 | `tags`, `userId`, `reviewCount` (key lain yang tidak ada di model: `mealType`) |

---

## 2. Screenshot Checkpoint 1 (wajib footer NIM/nama: 2411532014 - Jovantri Immanuel Gulo)

| File | Keterangan |
|---|---|
| `screenshots/cp1_home.png` | HomePage: indikator loading, lalu 50 resep dari server (terlihat resep selain 6 dummy), footer NIM/nama |
| `screenshots/cp1_detail.png` | Halaman Detail setelah scroll: foto resep, porsi, bahan, dan bagian "Langkah", footer NIM/nama |

---

## 3. Screenshot Checkpoint 2 (wajib footer NIM/nama)

| File | Keterangan |
|---|---|
| `screenshots/cp2_error.png` | Mode pesawat + hot restart → ErrorView (ikon `wifi_off`, "Gagal memuat resep.", tombol "Coba lagi"), footer NIM/nama |
| `screenshots/cp2_refresh.png` | Matikan mode pesawat, tekan "Coba lagi" → daftar kembali. Lalu pull-to-refresh → indikator berputar di atas, daftar lama tetap terlihat, footer NIM/nama |

---

## 4. Screenshot Checkpoint 3 (wajib footer NIM/nama)

| File | Keterangan |
|---|---|
| `screenshots/cp3_form.png` | Tekan tombol `+` → form Tambah Resep, isi Rendang / Indonesian / 180, tekan Simpan. Form tertutup dan SnackBars menampilkan id dari server, footer NIM/nama |
| `screenshots/cp3_validasi.png` | Tekan tombol `+`, tekan Simpan dengan form kosong → pesan "Wajib diisi" muncul, tidak ada request terkirim, footer NIM/nama |

---

## 5. Tabel Uji Langkah D.1

| No | Skenario | Hasil yang diharapkan | Sesuai? |
|---|---|---|---|
| 1 | Buka aplikasi → loading, lalu 50 resep dari server | Loading muncul, kemudian 50 resep ditampilkan | ☑ |
| 2 | Tandai 2 resep favorit, tarik refresh → ikon hati tetap merah, badge tetap 2 | 2 favorit tetap tercentang, badge tetap 2 | ☑ |
| 3 | Tekan tombol grid, kembali ke list → tidak ada loading baru | Tampilan berubah tanpa loading ulang | ☑ |
| 4 | Buka detail salah satu resep → foto, porsi, bahan, langkah memasak tampil | Detail lengkap tampil | ☑ |
| 5 | Mode pesawat, hot restart → ErrorView + tombol "Coba lagi" | ErrorView muncul | ☑ |
| 6 | Matikan mode pesawat, tekan "Coba lagi" → daftar tampil kembali | Daftar resep kembali ditampilkan | ☑ |
| 7 | Kirim resep baru via tombol `+` → SnackBars berisi id dari server | SnackBar menampilkan id resep baru | ☑ |

---

## 6. Jawaban Pertanyaan Analisis

**1. Pada skenario 2, setiap refresh membuat objek Recipe baru dari JSON. Mengapa status favorit tetap benar? Hubungkan dengan cara FavoriteProvider membandingkan resep (Modul 6).**

Status favorit tetap benar karena `FavoriteProvider` membandingkan resep berdasarkan nilai `id`, bukan identitas objek. Pada `favorite_provider.dart:10`, `isFavorite` menggunakan `_items.any((r) => r.id == recipe.id)`. Meskipun `refresh` membuat objek `Recipe` baru dari JSON, nilainya `id` tetap sama, sehingga pengecocokan masih berhasil dan ikon hati tetap tercentang.

**2. Pada skenario 3, mengapa menekan tombol grid tidak memunculkan indikator loading? Apa yang akan terjadi jika future ditulis langsung di dalam build()?**

Tombol grid hanya mengubah flag `_isGrid` melalui `setState`, namun `_recipesFuture` dibuat sekali di `initState` dan tidak ditarik ulang. FutureBuilder menggunakan future yang sama yang sudah selesai (`ConnectionState.done`), sehingga tidak menampilkan loading lagi. Jika future ditulis langsung di dalam `build()`, setiap `setState` akan membuat `Future` baru, memicu fetch berulang dan menampilkan loading pada setiap rebuild — yangboros dan merusak UX.

**3. HomePage tidak memanggil http.get secara langsung, melainkan melalui RecipeService. Sebutkan dua keuntungan cara ini.**

Pertama, pemisahan tanggung jawab: semua logika HTTP (base URL, timeout 10 detik, `_checkStatus`, decode JSON) terpusat di `RecipeService`, sehingga UI tidak perlu mengetahui detail jaringan. Kedua, kemudahan pengujian: `RecipeService` dapat menerima `http.Client` palsu (`MockClient`) melalui konstruktor, sehingga unit test dapat menyimulasikan respons tanpa jaringan nyata.

**4. Setelah POST berhasil, server memberi id baru, tetapi resep tidak muncul saat daftar dimuat ulang. Jelaskan penyebabnya, dan bagaimana aplikasi dengan server sungguhan biasanya menampilkan data yang baru ditambahkan.**

Penyebabnya: dummyjson hanya mensimulasikan penyimpanan dan tidak benar-benar menambahkan resep baru ke daftar `GET /recipes?limit=50`, jadi resep baru tidak ikut muncul saat dimuat ulang. Pada server sungguhan, aplikasi biasanya menyegarkan daftar setelah POST (memanggil `fetchRecipes()` lagi), atau menyisipkan objek resep yang dikembalikan server langsung ke dalam daftar lokal/provider tanpa memuat ulang seluruhnya.

**5. Di AddRecipePage terdapat `if (!mounted) return;` setelah await. Jelaskan skenario yang dicegah oleh baris tersebut.**

Baris itu mencegah akses ke `BuildContext` yang sudah tidak mounted, misalnya saat pengguna menekan tombol Back atau menutup halaman saat proses `await service.addRecipe()` masih berjalan. Tanpa pemeriksaan ini, `Navigator.pop`, `setState`, atau `ScaffoldMessenger` pada widget yang sudah disposed akan memicu error "Cannot use BuildContext that doesn't exist".

---

## 7. Screenshot Latihan 1 & 2

| File | Keterangan |
|---|---|
| `screenshots/latihan1_hasil.png` | Pencarian "pasta" → hasil ditampilkan dengan FutureBuilder |
| `screenshots/latihan1_kosong.png` | Pencarian kata kunci tidak cocok → "Tidak ada resep yang cocok." |
| `screenshots/latihan1_error.png` | Pencarian saat offline → ErrorView ("Gagal mencari resep.") |
| `screenshots/latihan2_ubah.png` | Detail resep → PopupMenu "Ubah nama" → AlertDialog + PUT → SnackBar nama baru |
| `screenshots/latihan2_hapus.png` | Detail resep → PopupMenu "Hapus" → konfirmasi + DELETE → SnackBar + halaman ditutup |

---

## Catatan Penting

- **Jangan mengubah kode yang sudah ada** (Bagian C, Latihan 1, 2, 3 sudah selesai & lolos analisis). Hanya tambahkan screenshot dan laporan.
- **Footer NIM/nama (IdentityFooter) WAJIB terlihat di semua screenshot.** Screenshot tanpa footer atau dengan identitas orang lain tidak dinilai.
- Screenshot diambil dengan menjalankan aplikasi di emulator Android/HP (bukan web): `flutter run -d <device_id>`.
