import 'package:cloud_firestore/cloud_firestore.dart';
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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _heartAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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

    final result = await _authService.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim()
    );

    if (result['user'] != null) {
      final String uid = result['user'].uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      bool isComplete = false;
      if (userDoc.exists) {
        isComplete = userDoc.data()?['isProfileComplete'] ?? false;
      }

      setState(() => _isLoading = false);

      if (mounted) {
        if (isComplete) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/complete-profile');
        }
      }
    } else {
      setState(() => _isLoading = false);
      _showErrorSnackBar(result['error']);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.pinkAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const SizedBox(height: 80),
            ScaleTransition(
              scale: _heartAnimation,
              child: const Icon(Icons.favorite, size: 100, color: Colors.pinkAccent),
            ),
            const SizedBox(height: 30),
            Text("Love Space", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.pink[800])),
            const Text("Masuk ke ruang rahasia kalian"),
            const SizedBox(height: 50),
            _buildInput("Email", Icons.email_outlined, controller: _emailController),
            const SizedBox(height: 20),
            _buildInput("Password", Icons.lock_outline, isPass: true, controller: _passwordController),
            const SizedBox(height: 40),
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
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}