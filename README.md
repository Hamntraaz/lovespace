Ini dia draft **README.md** yang keren dan profesional buat proyek **Love Space** kamu. Deskripsinya sudah saya sesuaikan dengan fitur-fitur yang kita buat tadi (Informatics Engineering style banget!).

---

# ❤️ Love Space

**Love Space** adalah aplikasi *private dashboard* dan chat eksklusif yang dirancang khusus untuk pasangan. Aplikasi ini memungkinkan dua pengguna untuk terhubung dalam satu "ruang digital" pribadi untuk berbagi pesan, momen, dan memantau hari jadi (*anniversary*).

Dibuat dengan **Flutter** dan **Firebase**, aplikasi ini mengutamakan privasi dan pengalaman pengguna yang minimalis namun estetis.

---

## ✨ Fitur Utama
* **Private Chat:** Mengobrol aman dengan pasangan tanpa gangguan pihak ketiga.
* **Couple Dashboard:** Menampilkan profil pasangan, status hubungan, dan hitung mundur hari jadi.
* **Anniversary Indicator:** Animasi khusus (seperti jantung berdetak atau confetti) yang muncul otomatis saat hari jadi tiba.
* **Smart Auth:** Sistem login dan daftar dengan validasi warna (Email validasi & indikator kekuatan password).
* **Real-time Typing:** Indikator saat pasangan sedang mengetik pesan.
* **Media Sharing:** Berbagi foto dan momen langsung ke dalam chat menggunakan integrasi Cloudinary.

---

## 🛠️ Tech Stack
* **Frontend:** Flutter (Dart)
* **Backend:** Firebase (Authentication, Firestore)
* **State Management:** Stateful Widgets
* **Storage:** Cloudinary (via API)
* **UI/UX:** Google Fonts, Animate Do

---

## 🚀 Cara Menjalankan Proyek (Clone & Run)

Ikuti langkah-langkah ini untuk menjalankan Love Space di perangkat lokal kamu:

### 1. Clone Repository
Buka terminal kamu dan jalankan perintah berikut:
```bash
git clone https://github.com/Hanmtraaz/lovespace.git
cd lovespace
```

### 2. Install Dependencies
Pastikan kamu sudah menginstal Flutter SDK. Jalankan perintah untuk mendownload library yang dibutuhkan:
```bash
flutter pub get
```

### 3. Konfigurasi Firebase
Karena proyek ini menggunakan Firebase, kamu perlu menambahkan file konfigurasi sendiri:
* Buat proyek baru di [Firebase Console](https://console.firebase.google.com/).
* Daftarkan aplikasi Android (pakai package name: `com.revan.lovespace`).
* Download file `google-services.json` dan letakkan di folder `android/app/`.

### 4. Jalankan Aplikasi
Hubungkan HP (lewat Wireless Debugging atau kabel) atau buka Emulator, lalu jalankan:
```bash
flutter run
```

---

## 📂 Struktur Folder Penting
* `lib/features/auth/` : Berisi halaman login, register, dan loading screen.
* `lib/pages/` : Berisi halaman utama (Home, Dashboard).
* `lib/services/` : Logika Firebase dan autentikasi.
* `lib/features/chat/` : Semua logika sistem pesan pribadi.

---

## 📝 Catatan Pengembang (Revan)
Proyek ini masih dalam tahap pengembangan aktif oleh mahasiswa **Informatika**. Fokus utama saat ini adalah stabilitas sinkronisasi data antar pasangan dan integrasi AI untuk deteksi gestur di masa depan.

---

> **"Hubungkan hatimu dengan si dia, dalam ruang digital yang pribadi."** ❤️

---

### Cara Pakai:
1. Salin teks di atas.
2. Buka file `README.md` di root folder proyek kamu.
3. Hapus isinya, lalu *paste* kode di atas.
4. Simpan dan *push* ke GitHub kamu!
