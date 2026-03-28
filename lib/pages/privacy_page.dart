import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

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
        title: Text("Privasi", style: TextStyle(color: Colors.pink[800], fontWeight: FontWeight.bold)),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "Data kamu aman di Love Space. Kami tidak membagikan informasi pribadi atau riwayat chat kamu kepada pihak ketiga mana pun.",
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}