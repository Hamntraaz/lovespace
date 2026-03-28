import 'package:flutter/material.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  bool _codeSent = false;
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  void _handleSendCode() {
    if (_emailController.text.contains('@')) {
      setState(() => _codeSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kode verifikasi telah dikirim ke email baru!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.pinkAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Ganti Email", style: TextStyle(color: Colors.pink[800], fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _codeSent ? "Masukkan Kode Verifikasi" : "Email Baru",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _codeSent
                  ? "Kami telah mengirimkan 6 digit kode ke ${_emailController.text}"
                  : "Masukkan alamat email baru kamu. Kami akan mengirimkan kode verifikasi.",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            _codeSent
                ? _buildInput("Kode OTP", Icons.vibration, _otpController, isOtp: true)
                : _buildInput("Email Baru", Icons.email_outlined, _emailController),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _codeSent ? () => Navigator.pop(context) : _handleSendCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                _codeSent ? "Verifikasi & Simpan" : "Kirim Kode",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, IconData icon, TextEditingController controller, {bool isOtp = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.05), blurRadius: 10)],
      ),
      child: TextField(
        controller: controller,
        keyboardType: isOtp ? TextInputType.number : TextInputType.emailAddress,
        textAlign: isOtp ? TextAlign.center : TextAlign.start,
        style: TextStyle(letterSpacing: isOtp ? 10 : 1),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: isOtp ? null : Icon(icon, color: Colors.pinkAccent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }
}