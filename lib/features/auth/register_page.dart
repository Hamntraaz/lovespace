import 'package:flutter/material.dart';
import '../../services/auth_services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleRegister() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Isi semua datanya dulu ya sayang...")),
      );
      return;
    }

    setState(() => _isLoading = true);
    // Memanggil fungsi register baru yang menyimpan ke Firestore
    final user = await _authService.registerWithEmail(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
    );
    setState(() => _isLoading = false);

    if (user != null) {
      if (mounted) {
        Navigator.pop(context); // Kembali ke login setelah sukses
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Daftar gagal, coba periksa email/internet kamu")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.pinkAccent)
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ayo Daftar,", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.pink[800])),
            const Text("Buat ruang rahasia kalian berdua"),
            const SizedBox(height: 40),
            // Input Nama Baru agar tersimpan di Firestore
            _buildInput("Nama Lengkap", Icons.person_outline, controller: _nameController),
            const SizedBox(height: 15),
            _buildInput("Email", Icons.email_outlined, controller: _emailController),
            const SizedBox(height: 15),
            _buildInput("Password", Icons.lock_outline, isPass: true, controller: _passwordController),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Daftar Sekarang", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, IconData icon, {bool isPass = false, required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.pinkAccent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}