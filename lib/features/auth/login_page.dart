import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _controller;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _heartAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar("Email dan password diisi dulu ya!");
      return;
    }

    setState(() => _isLoading = true);

    // PERBAIKAN DI SINI: Memakai loginWithEmail sesuai auth_services.dart kamu
    final result = await _authService.loginWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['user'] != null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Mengambil pesan error romantis yang sudah kamu buat di AuthService
      _showErrorSnackBar(result['error'] ?? "Ada masalah pas masuk nih..");
    }
  }

  // --- LOGIKA LUPA PASSWORD ---
  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Reset Password"),
        content: TextField(
          controller: resetEmailController,
          decoration: const InputDecoration(
            hintText: "Masukkan Email kamu",
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.pinkAccent)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: () async {
              if (resetEmailController.text.isEmpty) return;
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: resetEmailController.text.trim());
                Navigator.pop(context);
                _showSuccessSnackBar("Link reset sudah dikirim ke email kamu!");
              } catch (e) {
                _showErrorSnackBar("Gagal: Email tidak ditemukan.");
              }
            },
            child: const Text("Kirim", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- LOGIKA CARI AKUN (LUPA AKUN) ---
  void _showFindAccountDialog() {
    final TextEditingController usernameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Cari Email Akun"),
        content: TextField(
          controller: usernameController,
          decoration: const InputDecoration(hintText: "Masukkan Username kamu"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: () async {
              if (usernameController.text.isEmpty) return;
              String username = usernameController.text.trim();

              var userQuery = await FirebaseFirestore.instance
                  .collection('users')
                  .where('name', isEqualTo: username)
                  .limit(1)
                  .get();

              if (userQuery.docs.isNotEmpty) {
                String fullEmail = userQuery.docs.first.get('email');
                String maskedEmail = _maskEmail(fullEmail);

                Navigator.pop(context);
                _showResultDialog("Akun Ditemukan!", "Email kamu adalah:\n$maskedEmail");
              } else {
                _showErrorSnackBar("Username tidak ditemukan.");
              }
            },
            child: const Text("Cari", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    String name = parts[0];
    if (name.length <= 2) return email;
    return "${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@${parts[1]}";
  }

  void _showResultDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(content, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
        actions: [
          Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("Oke, Saya Ingat!"))),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  void _showSuccessSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 100),
            ScaleTransition(
              scale: _heartAnimation,
              child: const Icon(Icons.favorite, size: 100, color: Colors.pinkAccent),
            ),
            const SizedBox(height: 30),
            Text("Masuk ke Love Space",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink[800])),
            const SizedBox(height: 40),
            _buildInput("Email", Icons.email, controller: _emailController),
            const SizedBox(height: 20),
            _buildInput("Password", Icons.lock, isPass: true, controller: _passwordController),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _showForgotPasswordDialog,
                  child: Text("Lupa Password?", style: TextStyle(color: Colors.pink[300], fontSize: 13)),
                ),
                TextButton(
                  onPressed: _showFindAccountDialog,
                  child: Text("Lupa Akun?", style: TextStyle(color: Colors.pink[300], fontSize: 13)),
                ),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Masuk", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text("Belum punya akun? Daftar di sini", style: TextStyle(color: Colors.pink[400])),
            )
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
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }
}