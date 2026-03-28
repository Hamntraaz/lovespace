import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _isChatNotif = true;
  bool _isAnnivNotif = true;

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
        title: Text("Notifikasi",
            style: TextStyle(color: Colors.pink[800], fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSwitchTile("Notifikasi Chat", _isChatNotif, (val) {
            setState(() => _isChatNotif = val);
          }),
          _buildSwitchTile("Pengingat Anniversary", _isAnnivNotif, (val) {
            setState(() => _isAnnivNotif = val);
          }),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        value: value,
        activeColor: Colors.pinkAccent,
        onChanged: onChanged,
      ),
    );
  }
}