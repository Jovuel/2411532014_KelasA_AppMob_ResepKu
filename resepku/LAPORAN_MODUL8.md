# Laporan Praktikum Modul 8 — HTTP Request & Integrasi API (ResepKu)

- **NIM:** 2411532014
- **Nama:** Jovantri Immanuel Gulo
- **Proyek:** `resepku` (Flutter)
- **Endpoint:** `https://dummyjson.com`

---

## A. Langkah A.1 — Eksplorasi Endpoint `https://dummyjson.com/recipes?limit=2`

| Pertanyaan | Jawaban |
| --- | --- |
| Nilai total | **50** (field `total`) |
| Key yang berisi daftar resep | **`recipes`** (array of object resep) |
| Tipe nilai rating pada resep pertama (int atau double?) | **double** — nilainya `4.6` (bilangan pecahan, diparse Dart menjadi `double`) |
| Tiga key resep yang belum ada di model `Recipe` Modul 7 | **`tags`**, **`userId`**, **`reviewCount`** (selain itu juga ada `mealType`) |

Contoh potongan JSON yang diamati:

```json
{
  "recipes": [
    {
      "id": 1,
      "name": "Classic Margherita Pizza",
      "cuisine": "Italian",
      "rating": 4.6,
      "tags": ["Pizza", "Italian"],
      "userId": 166,
      "reviewCount": 98,
      "mealType": ["Dinner"]
    }
  ],
  "total": 50,
  "skip": 0,
  "limit": 2
}
```

Catatan: field `rating` bertipe `double`, karena itu `Recipe.fromJson` memakai `(json['rating'] as num).toDouble()` agar aman baik saat server mengirim `int` maupun `double`.

---

## B. Checkpoint 1 — Data dari Server (15%)

| File | Keterangan yang harus tampak |
| --- | --- |
| `screenshots/cp1_home.png` | Home: indikator loading → 50 resep dari server (memperlihatkan resep yang tidak ada di 6 resep dummy), footer NIM/Nama terlihat |
| `screenshots/cp1_detail.png` | Detail setelah di-scroll: foto, porsi, bahan, bagian "Langkah", footer NIM/Nama terlihat |

## C. Checkpoint 2 — Error & Refresh (10%)

| File | Keterangan yang harus tampak |
| --- | --- |
| `screenshots/cp2_error.png` | Mode pesawat → hot restart → `ErrorView` (ikon `wifi_off`, "Gagal memuat resep.", tombol "Coba lagi"), footer NIM/Nama terlihat |
| `screenshots/cp2_refresh.png` | Mode pesawat dimatikan → "Coba lagi" → daftar tampil kembali; pull-to-refresh berputar di atas dan daftar lama tetap terlihat, footer NIM/Nama terlihat |

## C.3 Checkpoint 3 — Tambah Resep & Validasi (10%)

| File | Keterangan yang harus tampak |
| --- | --- |
| `screenshots/cp3_form.png` | Form Tambah Resep (Rendang / Indonesian / 180) → Simpan → form tertutup & SnackBar memuat id dari server, footer NIM/Nama terlihat |
| `screenshots/cp3_validasi.png` | Simpan dengan form kosong → pesan "Wajib diisi" muncul, tidak ada request dikirim, footer NIM/Nama terlihat |

---

## D. Tabel Uji (Langkah D.1)

| No | Skenario | Hasil yang diharapkan | Sesuai? |
| --- | --- | --- | --- |
| 1 | Buka aplikasi | Loading singkat, lalu 50 resep dari server ditampilkan | Ya |
| 2 | Tandai 2 resep favorit, lalu tarik refresh | Ikon hati tetap merah, badge tetap 2 | Ya |
| 3 | Tekan tombol grid, kembali ke list | Tidak ada loading baru | Ya |
| 4 | Buka detail salah satu resep | Foto, porsi, bahan, langkah memasak tampil | Ya |
| 5 | Mode pesawat, hot restart | `ErrorView` + tombol "Coba lagi" tampil | Ya |
| 6 | Matikan mode pesawat, tekan "Coba lagi" | Daftar tampil kembali | Ya |
| 7 | Kirim resep baru via tombol + | SnackBar berisi id dari server | Ya |

---

## E. Jawaban Pertanyaan Analisis

**1. Pada skenario 2, setiap refresh membuat objek `Recipe` baru dari JSON. Mengapa status favorit tetap benar?**

Status favorit tetap benar karena `FavoriteProvider` membandingkan resep berdasarkan **`id`**, bukan berdasarkan identitas objek (`identity`/`==` bawaan). Method `isFavorite()` menjalankan `_items.any((r) => r.id == recipe.id)`, sehingga walaupun refresh menghasilkan instance `Recipe` yang benar-benar baru, selama `id`-nya sama, resep tersebut tetap dikenali sebagai favorit. Daftar favorit juga disimpan di provider (state di luar widget), jadi tidak ikut ter-reset saat data home dimuat ulang.

**2. Pada skenario 3, mengapa menekan tombol grid tidak memunculkan indikator loading? Apa yang akan terjadi jika future ditulis langsung di dalam `build()`?**

Menekan tombol grid hanya mengubah `_isGrid` lewat `setState`, sementara `_recipesFuture` dibuat **sekali** di `initState` dan disimpan sebagai field. `FutureBuilder` menerima `future` yang sama dan sudah selesai (`completed`), sehingga langsung menampilkan data tanpa kembali ke status loading. Jika future ditulis langsung di dalam `build()`, setiap rebuild (mis. saat toggle grid, tema berubah, atau scroll) akan membuat `Future` yang benar-benar baru; `FutureBuilder` menganggapnya future baru sehingga kembali menampilkan `CircularProgressIndicator` dan memicu request berulang-ulang ke server setiap kali widget dibangun ulang.

**3. HomePage tidak memanggil `http.get` secara langsung, melainkan melalui `RecipeService`. Sebutkan dua keuntungan cara ini.**

Dua keuntungan utamanya: (a) **Pemisahan tanggung jawab (separation of concerns)** — UI hanya fokus menampilkan data, sedangkan detail teknis (URL, header, timeout, pengecekan status, parsing JSON) terisolasi di service, sehingga lebih mudah dirawat dan diubah tanpa menyentuh halaman; (b) **Dapat digunakan ulang dan mudah diuji** — base URL, timeout, dan pemetaan error hanya ditulis sekali dan dipakai bersama oleh HomePage, SearchPage, AddRecipePage, dan DetailPage, sekaligus memudahkan pengujian karena `http.Client` bisa disuntikkan.

**4. Setelah POST berhasil, server memberi id baru, tetapi resep tidak muncul saat daftar dimuat ulang. Jelaskan penyebabnya, dan bagaimana aplikasi dengan server sungguhan biasanya menampilkan data yang baru ditambahkan.**

Penyebabnya karena `https://dummyjson.com/recipes/add` hanya **menyimulasikan** penyimpanan: server mengembalikan objek yang dikirim beserta `id` baru, tetapi **tidak menyimpannya** ke data sumber. Ketika `GET /recipes` dipanggil ulang, server mengembalikan 50 resep seed yang sama, sehingga resep baru tidak ikut muncul. Aplikasi dengan server sungguhan biasanya menangani ini dengan menyimpan data ke database di backend, lalu menampilkan hasil terbaru melalui salah satu pendekatan: memuat ulang daftar setelah data benar-benar tersimpan, atau melakukan *optimistic update* dengan langsung menambahkan objek hasil `POST` ke daftar saat itu juga (dan menyinkronkan kembali dengan data server pada refresh berikutnya).

**5. Di `AddRecipePage` terdapat `if (!mounted) return;` setelah `await`. Jelaskan skenario yang dicegah oleh baris tersebut.**

Baris tersebut mencegah pemakaian `context`/`setState` pada widget yang sudah **dilepas (disposed)**. Karena `await` bersifat asynchronous dan memakan waktu, bisa saja selama request berjalan pengguna sudah meninggalkan halaman (menekan tombol back, menutup halaman, atau aplikasi di-restart). Tanpa `if (!mounted) return;`, pemanggilan `Navigator.pop(context, ...)` atau `setState(...)` setelah `await` akan menyentuh `State` yang sudah tidak aktif dan memicu error seperti *"use of ... after dispose"* / *"Looking up a deactivated widget's ancestor is unsafe"*. Baris itu memastikan halaman hanya bereaksi jika masih aktif.

---

## F. Latihan 1 — Pencarian (15%)

| File | Keterangan yang harus tampak |
| --- | --- |
| `screenshots/latihan1_hasil.png` | Ikon kaca pembesar → ketik "pasta" → Enter → hasil ditampilkan (`FutureBuilder`) |
| `screenshots/latihan1_kosong.png` | Hasil kosong ("Tidak ada resep yang cocok.") |
| `screenshots/latihan1_error.png` | Error state pencarian (`ErrorView`) |

## G. Latihan 2 — Ubah & Hapus (15%)

| File | Keterangan yang harus tampak |
| --- | --- |
| `screenshots/latihan2_ubah.png` | `PopupMenuButton` → "Ubah nama" → AlertDialog + PUT → SnackBar nama baru |
| `screenshots/latihan2_hapus.png` | "Hapus" → konfirmasi + DELETE → SnackBar + halaman tertutup |

---

Semua screenshot pada laporan ini menyertakan **footer NIM/Nama** (`IdentityFooter`: `2411532014 - Jovantri Immanuel Gulo`) yang dirender oleh `MaterialApp.builder` di `main.dart`.
