import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    String newPass = _newPasswordController.text.trim();
    String confirmPass = _confirmPasswordController.text.trim();

    // 1. Validasi Kecocokan
    if (newPass != confirmPass) {
      _showSnackBar("Password baru dan konfirmasi tidak cocok!");
      return;
    }

    // 2. Validasi Karakter (8+ Karakter, Huruf Besar, Angka)
    if (newPass.length < 8 || !newPass.contains(RegExp(r'[A-Z]')) || !newPass.contains(RegExp(r'[0-9]'))) {
      _showSnackBar("Password harus 8+ karakter, ada huruf besar & angka!");
      return;
    }

    setState(() => _isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;

      // 3. Re-authenticate (Wajib untuk ganti password)
      AuthCredential credential = EmailAuthProvider.credential(
          email: user?.email ?? "",
          password: _oldPasswordController.text
      );
      await user?.reauthenticateWithCredential(credential);

      // 4. Update Password
      await user?.updatePassword(newPass);

      if (mounted) {
        _showSnackBar("Password berhasil diperbarui!");
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Gagal memperbarui password");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.pinkAccent), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const Icon(Icons.lock_outline, size: 70, color: Colors.pinkAccent),
            const SizedBox(height: 20),
            _buildInput("Password Lama", Icons.lock_open, _oldPasswordController, true),
            const SizedBox(height: 15),
            _buildInput("Password Baru", Icons.lock_reset, _newPasswordController, true),
            const SizedBox(height: 15),
            _buildInput("Konfirmasi Password Baru", Icons.verified_user_outlined, _confirmPasswordController, true),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _updatePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Simpan Password Baru", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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