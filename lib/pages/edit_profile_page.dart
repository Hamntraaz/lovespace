import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'account/change_email_page.dart';
import 'account/change_password_page.dart';
import 'account/reset_password_page.dart';

class EditProfilePage extends StatefulWidget {
  final String currentName;
  final String currentPhoto;

  const EditProfilePage({super.key, required this.currentName, required this.currentPhoto});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: FirebaseAuth.instance.currentUser?.email ?? "");
    _refreshUser();
  }

  Future<void> _refreshUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      setState(() {
        _emailController.text = FirebaseAuth.instance.currentUser?.email ?? "";
      });
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
        title: const Text("Edit Profil", style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        color: Colors.pinkAccent,
        onRefresh: _refreshUser,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(25),
          // SEKARANG PAKAI COLUMN, GA BAKAL EROR LAGI
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: widget.currentPhoto.isNotEmpty ? NetworkImage(widget.currentPhoto) : null,
                      child: widget.currentPhoto.isEmpty ? const Icon(Icons.person, size: 60, color: Colors.pinkAccent) : null,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: CircleAvatar(backgroundColor: Colors.pinkAccent, radius: 18, child: const Icon(Icons.camera_alt, size: 18, color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildInput("Nama Panggilan", Icons.person, _nameController, false),
              const SizedBox(height: 15),
              _buildInput("Email Utama", Icons.email_outlined, _emailController, true),
              const SizedBox(height: 30),
              const Divider(),
              const Align(alignment: Alignment.centerLeft, child: Text("Keamanan Akun", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
              const SizedBox(height: 15),
              _buildSecurityOption("Ubah Password", Icons.lock_reset, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
              }),
              _buildSecurityOption("Ganti Email Utama", Icons.alternate_email, () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangeEmailPage()));
                _refreshUser();
              }),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  setState(() => _isLoading = true);
                  try {
                    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).update({
                      'name': _nameController.text.trim(),
                    });
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    debugPrint(e.toString());
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String hint, IconData icon, TextEditingController controller, bool isReadOnly) {
    return Container(
      decoration: BoxDecoration(
        color: isReadOnly ? Colors.grey[200] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.05), blurRadius: 10)],
      ),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: isReadOnly ? Colors.grey : Colors.pinkAccent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }

  Widget _buildSecurityOption(String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.pinkAccent),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}