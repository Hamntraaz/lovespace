import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart'; // Import ini penting
import 'login_page.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double _progress = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() async {
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
      if (mounted) setState(() => _progress = i / 100);
    }
    setState(() => _isFinished = true);
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.location, Permission.notification].request();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tetap pakai asset logo kamu
            Image.asset('assets/images/logo.jpg', width: 150),
            const SizedBox(height: 50),
            if (!_isFinished) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.pink[100],
                  color: Colors.pinkAccent,
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 15),
              Text("${(_progress * 100).toInt()}%",
                  style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 18)),
            ] else
              ElevatedButton(
                onPressed: _requestPermissions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Get Started", style: TextStyle(fontSize: 18)),
              ),
          ],
        ),
      ),
    );
  }
}