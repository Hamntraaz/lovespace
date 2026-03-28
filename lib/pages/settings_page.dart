import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_page.dart';
import 'notification_page.dart';
import 'privacy_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Pilih Aksi", style: TextStyle(color: Colors.pink[800], fontWeight: FontWeight.bold)),
        content: const Text("Kamu ingin keluar dari akun atau tutup aplikasi saja?"),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: const Text("Keluar Akun", style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text("Tutup Aplikasi"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFFF0F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.pinkAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Pengaturan",
            style: TextStyle(color: _isDarkMode ? Colors.pink[200] : Colors.pink[800], fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var userData = snapshot.data!;
          String name = userData['name'] ?? 'User';
          String email = userData['email'] ?? '';
          String photoUrl = userData['photoUrl'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileCard(name, email, photoUrl),
                const SizedBox(height: 30),

                _buildMenuItem(Icons.person_outline, "Edit Profil", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfilePage(currentName: name, currentPhoto: photoUrl)));
                }),

                _buildMenuItem(Icons.notifications_none, "Notifikasi", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage()));
                }),

                _buildMenuItem(Icons.lock_outline, "Privasi", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPage()));
                }),

                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined, color: Colors.pinkAccent),
                  title: Text("Mode Gelap", style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87)),
                  trailing: Switch(
                    value: _isDarkMode,
                    activeColor: Colors.pinkAccent,
                    onChanged: (val) => setState(() => _isDarkMode = val),
                  ),
                ),

                _buildMenuItem(Icons.info_outline, "Tentang Aplikasi", () {
                  showAboutDialog(
                    context: context,
                    applicationName: "Love Space",
                    applicationVersion: "1.0.0",
                    applicationIcon: const Icon(Icons.favorite, color: Colors.pinkAccent, size: 40),
                  );
                }),
                const Divider(height: 40),
                _buildMenuItem(Icons.logout, "Keluar", () => _showExitDialog(context), isLogout: true),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(String name, String email, String photoUrl) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            child: photoUrl.isEmpty ? const Icon(Icons.person, size: 35) : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _isDarkMode ? Colors.white : Colors.black87)),
                Text(email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.redAccent : Colors.pinkAccent),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.redAccent : (_isDarkMode ? Colors.white70 : Colors.black87))),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}