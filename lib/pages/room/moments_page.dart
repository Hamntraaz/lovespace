import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MomentsPage extends StatefulWidget {
  final String roomId;
  const MomentsPage({super.key, required this.roomId});
  @override
  State<MomentsPage> createState() => _MomentsPageState();
}

class _MomentsPageState extends State<MomentsPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadAction(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source);
    if (file != null) {
      // Logika upload ke Storage & Firestore dipasang di sini
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mengunggah kenangan...")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      appBar: AppBar(
        title: const Text("Gallery Moment", style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.add_a_photo, color: Colors.pinkAccent),
              onPressed: () => _showPickerOptions(context)
          ),
        ],
      ),
      body: const Center(child: Text("Mulai abadikan momen kalian", style: TextStyle(color: Colors.grey))),
    );
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(children: [
          ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Kamera'), onTap: () { Navigator.pop(context); _uploadAction(ImageSource.camera); }),
          ListTile(leading: const Icon(Icons.photo_library), title: const Text('Galeri'), onTap: () { Navigator.pop(context); _uploadAction(ImageSource.gallery); }),
        ]),
      ),
    );
  }
}