import 'package:flutter/material.dart';

class ChangePhonePage extends StatefulWidget {
  const ChangePhonePage({super.key});

  @override
  State<ChangePhonePage> createState() => _ChangePhonePageState();
}

class _ChangePhonePageState extends State<ChangePhonePage> {
  bool _codeSent = false;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

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
        title: Text("Ganti No. Telepon", style: TextStyle(color: Colors.pink[800], fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const Icon(Icons.phone_android, size: 80, color: Colors.pinkAccent),
            const SizedBox(height: 20),
            Text(_codeSent ? "Verifikasi Nomor" : "Update Nomor HP", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            _buildInput(
                _codeSent ? "Masukkan 6 Digit Kode" : "Nomor Baru (Contoh: 0812...)",
                _codeSent ? Icons.lock_clock_outlined : Icons.phone,
                _codeSent ? _otpController : _phoneController,
                isOtp: _codeSent
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                if (!_codeSent) {
                  setState(() => _codeSent = true);
                } else {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(_codeSent ? "Konfirmasi" : "Lanjut", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        keyboardType: TextInputType.number,
        textAlign: isOtp ? TextAlign.center : TextAlign.start,
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