import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final _oldPasswordController = TextEditingController();
  final _newEmailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updateEmail() async {
    if (!_newEmailController.text.contains('@')) {
      _showSnackBar("Format email baru tidak valid!");
      return;
    }

    setState(() => _isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;

      // 1. Re-authenticate (Wajib agar Firebase mengizinkan ganti email)
      AuthCredential credential = EmailAuthProvider.credential(
        email: user?.email ?? "",
        password: _oldPasswordController.text,
      );
      await user?.reauthenticateWithCredential(credential);

      // 2. Kirim email verifikasi ke alamat baru
      // Setelah user klik link di email baru, email di Firebase otomatis berubah
      await user?.verifyBeforeUpdateEmail(_newEmailController.text.trim());

      if (mounted) {
        _showSnackBar("Link verifikasi dikirim ke ${_newEmailController.text}. Silakan cek inbox/spam!");
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Gagal memperbarui email");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ganti Email Utama", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.pinkAccent)),
            const SizedBox(height: 10),
            const Text("Demi keamanan, konfirmasi password kamu untuk mengganti email.", style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 30),
            _buildInput("Password Saat Ini", Icons.lock_outline, _oldPasswordController, true),
            const SizedBox(height: 15),
            _buildInput("Email Baru", Icons.alternate_email, _newEmailController, false),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Kirim Link Verifikasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, IconData icon, TextEditingController controller, bool isPass) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.pinkAccent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }
}