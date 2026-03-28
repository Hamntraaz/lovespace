import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// PASTIKAN IMPORT INI BENAR SESUAI STRUKTUR FOLDERMU
import 'account/change_email_page.dart';
import 'account/change_phone_page.dart';
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
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  String _selectedGender = 'Pria';
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _phoneController = TextEditingController();
    _dobController = TextEditingController();
    _loadAdditionalData();
  }

  void _loadAdditionalData() async {
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (doc.exists) {
      setState(() {
        _phoneController.text = doc.data()?['phone'] ?? '';
        _dobController.text = doc.data()?['dob'] ?? '';
        _selectedGender = doc.data()?['gender'] ?? 'Pria';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.pinkAccent),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _pickAndCropImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Potong Foto',
            toolbarColor: Colors.pinkAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() => _imageFile = File(croppedFile.path));
      }
    }
  }

  Future<String?> _uploadToCloudinary() async {
    if (_imageFile == null) return widget.currentPhoto;
    final url = Uri.parse('https://api.cloudinary.com/v1_1/dubjinrem/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'PpLoveSpace'
      ..files.add(await http.MultipartFile.fromPath('file', _imageFile!.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final jsonResponse = jsonDecode(String.fromCharCodes(responseData));
      return jsonResponse['secure_url'];
    }
    return null;
  }

  void _updateProfile() async {
    setState(() => _isLoading = true);
    String? imageUrl = await _uploadToCloudinary();

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'name': _nameController.text,
        'photoUrl': imageUrl,
        'phone': _phoneController.text,
        'dob': _dobController.text,
        'gender': _selectedGender,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil diperbarui!")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal update profil")));
    }
    setState(() => _isLoading = false);
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
        title: Text("Edit Profil & Akun", style: TextStyle(color: Colors.pink[800], fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAndCropImage,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : (widget.currentPhoto.isNotEmpty ? NetworkImage(widget.currentPhoto) : null) as ImageProvider?,
                child: (_imageFile == null && widget.currentPhoto.isEmpty)
                    ? const Icon(Icons.camera_alt, color: Colors.pinkAccent, size: 35)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            const Text("Ubah Foto", style: TextStyle(fontSize: 12, color: Colors.pinkAccent, fontWeight: FontWeight.bold)),

            const SizedBox(height: 30),
            _buildInput("Nama Panggilan", Icons.person_outline, controller: _nameController),
            const SizedBox(height: 15),
            _buildInput("Nomor Telepon", Icons.phone_android_outlined, controller: _phoneController, isPhone: true),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: _buildInput("Tanggal Lahir", Icons.cake_outlined, controller: _dobController),
              ),
            ),
            const SizedBox(height: 15),
            _buildGenderDropdown(),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),

            const Divider(height: 50),
            Align(alignment: Alignment.centerLeft, child: Text("Keamanan Akun", style: TextStyle(color: Colors.pink[800], fontWeight: FontWeight.bold))),
            const SizedBox(height: 15),

            // FIX: Navigasi ke Halaman di folder Account
            _buildSecurityOption("Lupa / Ubah Password", Icons.lock_reset, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordPage()));
            }),
            _buildSecurityOption("Ganti Email Utama", Icons.email_outlined, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangeEmailPage()));
            }),
            _buildSecurityOption("Ganti Nomor Telepon", Icons.phone_android_outlined, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePhonePage()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.05), blurRadius: 10)],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.pinkAccent),
          items: ['Pria', 'Wanita'].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (val) => setState(() => _selectedGender = val!),
        ),
      ),
    );
  }

  Widget _buildInput(String hint, IconData icon, {required TextEditingController controller, bool isPhone = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.05), blurRadius: 10)],
      ),
      child: TextField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.pinkAccent),
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
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}