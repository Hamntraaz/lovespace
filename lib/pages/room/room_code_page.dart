import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoomCodePage extends StatelessWidget {
  final String roomCode;

  const RoomCodePage({super.key, required this.roomCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3), // Tetap Soft Pink
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Biar user fokus di sini
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.close, color: Colors.pinkAccent),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration_rounded, size: 80, color: Colors.pinkAccent),
              const SizedBox(height: 20),
              const Text(
                "Ruangan Berhasil Dibuat!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Bagikan kode ini ke pasanganmu agar kalian bisa terhubung.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 40),

              // BOX KODE
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "KODE ROOM",
                      style: TextStyle(letterSpacing: 2, fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      roomCode,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 10,
                        color: Colors.pinkAccent,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // TOMBOL COPY
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: roomCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Kode berhasil disalin!"),
                      backgroundColor: Colors.pinkAccent,
                    ),
                  );
                },
                icon: const Icon(Icons.copy_all_rounded, color: Colors.white),
                label: const Text("Salin Kode", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),

              const SizedBox(height: 60),

              const Text(
                "Setelah pasanganmu memasukkan kode ini,\nhalaman utama kalian akan otomatis berubah.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text("Selesai & Ke Beranda", style: TextStyle(color: Colors.pinkAccent)),
              )
            ],
          ),
        ),
      ),
    );
  }
}