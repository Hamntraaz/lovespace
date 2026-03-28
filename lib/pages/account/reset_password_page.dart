import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  Future<void> _sendResetEmail(BuildContext context) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    try {
      // Firebase akan mengirimkan email berisi link.
      // Saat diklik, user akan diarahkan ke halaman web reset password bawaan Firebase/Aplikasi kamu.
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        _showSuccessDialog(context, email);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mengirim link reset. Coba lagi nanti.")));
    }
  }

  void _showSuccessDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Email Terkirim"),
        content: Text("Silakan cek inbox Gmail kamu ($email) dan klik link untuk mengatur ulang password."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK", style: TextStyle(color: Colors.pinkAccent))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read_outlined, size: 100, color: Colors.pinkAccent),
            const SizedBox(height: 30),
            const Text("Lupa Password?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const Text(
              "Kami akan mengirimkan link reset password resmi ke email akun kamu yang terdaftar.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _sendResetEmail(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Kirim Link Reset", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}