import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  File? _imageFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  Future<void> _pickAndCropImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Potong Foto Profil',
            toolbarColor: Colors.pinkAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
          IOSUiSettings(
            title: 'Potong Foto Profil',
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _imageFile = File(croppedFile.path);
        });
      }
    }
  }

  Future<String?> _uploadToCloudinary() async {
    if (_imageFile == null) return null;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.2;
    });

    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/dubjinrem/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'PpLoveSpace'
        ..files.add(await http.MultipartFile.fromPath('file', _imageFile!.path));

      setState(() => _uploadProgress = 0.5);

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonResponse = jsonDecode(responseString);

        setState(() => _uploadProgress = 1.0);
        return jsonResponse['secure_url'];
      }
    } catch (e) {
      debugPrint("Upload Error: $e");
    }
    return null;
  }

  void _saveProfile() async {
    if (_nameController.text.isEmpty) {
      _showSnackBar("Isi nama panggilanmu dulu ya!");
      return;
    }

    String? imageUrl;
    if (_imageFile != null) {
      imageUrl = await _uploadToCloudinary();
      if (imageUrl == null) {
        _showSnackBar("Gagal upload foto, coba lagi ya.");
        setState(() => _isUploading = false);
        return;
      }
    }

    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'name': _nameController.text,
        'photoUrl': imageUrl ?? '',
        'isProfileComplete': true,
      });

      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showSnackBar("Gagal menyimpan data.");
    }
    setState(() => _isUploading = false);
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.pinkAccent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text("Lengkapi Profil",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.pink[800])),
              const SizedBox(height: 10),
              const Text("Biar pasanganmu makin rindu!"),
              const SizedBox(height: 30),

              GestureDetector(
                onTap: _isUploading ? null : _pickAndCropImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 140, width: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.pinkAccent, width: 3),
                        image: _imageFile != null
                            ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _imageFile == null
                          ? const Icon(Icons.add_a_photo_rounded, size: 45, color: Colors.pinkAccent)
                          : null,
                    ),
                    if (_isUploading)
                      SizedBox(
                        height: 150, width: 150,
                        child: CircularProgressIndicator(
                          value: _uploadProgress,
                          strokeWidth: 5,
                          color: Colors.pink[300],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              _buildInput("Nama Panggilan", Icons.favorite_rounded, controller: _nameController),
              const SizedBox(height: 30),

              if (_isUploading) ...[
                const Text("Sedang mengirim foto..."),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: _uploadProgress, color: Colors.pinkAccent, backgroundColor: Colors.pink[50]),
                const SizedBox(height: 20),
              ],

              ElevatedButton(
                onPressed: _isUploading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                ),
                child: _isUploading
                    ? const Text("Memproses...", style: TextStyle(color: Colors.white))
                    : const Text("Mulai Perjalanan Cinta", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String hint, IconData icon, {required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: TextField(
        controller: controller,
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