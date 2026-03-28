import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings_page.dart'; // Import agar bisa pindah halaman

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      // App Bar Lucu
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Love Space", style: TextStyle(color: Colors.pink[800], fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              // PINDAH KE HALAMAN SETTINGS
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings, color: Colors.pinkAccent),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var userData = snapshot.data!;
          String partnerId = userData['partnerId'] ?? '';

          // JIKA BELUM PUNYA PASANGAN (KONDISI KOSONG)
          if (partnerId.isEmpty) {
            return _buildEmptyState(context, userData['name']);
          }

          // JIKA SUDAH PUNYA PASANGAN
          return Center(child: Text("Halaman Pasangan (Coming Soon)"));
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, size: 80, color: Colors.pinkAccent),
          const SizedBox(height: 20),
          Text("Halo, $name!", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("Ruangmu masih sepi nih, ayo hubungkan dengan pasanganmu!", textAlign: TextAlign.center),
          const SizedBox(height: 40),

          // TOMBOL ADD FRIEND / SCAN QR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMenuAction(context, Icons.qr_code_scanner, "Scan QR"),
              _buildMenuAction(context, Icons.qr_code, "My QR"),
              _buildMenuAction(context, Icons.vpn_key, "Room Code"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuAction(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.2), blurRadius: 10)],
          ),
          child: Icon(icon, color: Colors.pinkAccent, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}