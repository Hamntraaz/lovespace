import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyQrPage extends StatelessWidget {
  const MyQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil User ID asli dari Firebase
    final user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? "No User ID Found";

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3), // Tetap Soft Pink
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.pinkAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
            "My QR Code",
            style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Tunjukkan QR ini ke Pasanganmu",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),

            // KONTEN QR ESTETIK
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.pink.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Generator QR Real dari UID
                  QrImageView(
                    data: uid,
                    version: QrVersions.auto,
                    size: 200.0,
                    foregroundColor: Colors.pink[800], // QR Warna Pink Gelap
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user?.displayName ?? "User Love Space",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "ID: ${uid.substring(0, 8)}...", // Tampilkan sebagian UID
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // Tombol Petunjuk
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Gunakan fitur Scan QR di HP pasanganmu untuk menautkan akun kalian selamanya.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.pink[300], fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}