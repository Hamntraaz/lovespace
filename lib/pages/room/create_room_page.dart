import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'room_code_page.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final _roomNameController = TextEditingController();
  final _maleNameController = TextEditingController();
  final _femaleNameController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  // LOGIC REAL: Generate 6 Digit Unik
  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  // UI DEAL: Pink Accent Date Picker
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.pinkAccent,
              onPrimary: Colors.white,
              onSurface: Colors.pink,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // LOGIC REAL: Simpan ke Firebase
  Future<void> _handleCreateRoom() async {
    if (_roomNameController.text.isEmpty ||
        _selectedDate == null ||
        _maleNameController.text.isEmpty ||
        _femaleNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua data wajib diisi!")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final roomCode = _generateRoomCode();

      // 1. Tambahkan ke koleksi rooms
      DocumentReference roomRef = await FirebaseFirestore.instance.collection('rooms').add({
        'roomName': _roomNameController.text.trim(),
        'maleName': _maleNameController.text.trim(),
        'femaleName': _femaleNameController.text.trim(),
        'location': _locationController.text.trim(),
        'anniversaryDate': _selectedDate,
        'roomCode': roomCode,
        'createdBy': user.uid,
        'members': [user.uid],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Hubungkan user ke room tersebut
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'roomId': roomRef.id,
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => RoomCodePage(roomCode: roomCode)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membuat ruangan: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3), // UI DEAL: Soft Pink
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Buat Ruangan Baru",
          style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.pinkAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const Icon(Icons.favorite, size: 50, color: Colors.pinkAccent),
            const SizedBox(height: 10),
            const Text(
              "Lengkapi detail ruang cinta kalian",
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 30),

            // FIX: Menggunakan Icons.bedroom_parent agar tidak error
            _buildInput("Nama Ruangan", Icons.bedroom_parent, _roomNameController),
            const SizedBox(height: 15),

            _buildInput("Panggilan Pria", Icons.male, _maleNameController),
            const SizedBox(height: 15),

            _buildInput("Panggilan Wanita", Icons.female, _femaleNameController),
            const SizedBox(height: 15),

            _buildInput("Lokasi", Icons.location_on, _locationController),
            const SizedBox(height: 15),

            // Anniversary Date Picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.pinkAccent),
                    const SizedBox(width: 15),
                    Text(
                      _selectedDate == null
                          ? "Tanggal Jadian"
                          : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                      style: TextStyle(
                          color: _selectedDate == null ? Colors.grey : Colors.black87,
                          fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: _isLoading ? null : _handleCreateRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                shadowColor: Colors.pinkAccent.withOpacity(0.3),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                  "Buat & Dapatkan Kode",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, IconData icon, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.05), blurRadius: 10)],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.pinkAccent, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }
}