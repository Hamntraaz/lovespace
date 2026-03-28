import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'settings_page.dart';
import 'room/create_room_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _codeController = TextEditingController();
  bool _isProcessing = false;

  Future<void> _processJoin(String inputCode) async {
    String code = inputCode.trim().toUpperCase();
    if (code.length < 6) return;

    if (mounted) setState(() => _isProcessing = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      var roomQuery = await FirebaseFirestore.instance
          .collection('rooms')
          .where('roomCode', isEqualTo: code)
          .limit(1)
          .get();

      if (roomQuery.docs.isNotEmpty) {
        String roomId = roomQuery.docs.first.id;
        await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
          'members': FieldValue.arrayUnion([user!.uid])
        });
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'roomId': roomId
        });
        _showSnackBar("Berhasil bergabung!");
      } else {
        _showSnackBar("Kode tidak ditemukan");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSnackBar(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Love Space", style: TextStyle(color: Colors.pink[800], fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
              icon: const Icon(Icons.settings, color: Colors.pinkAccent)),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));

          var userData = snapshot.data?.data() as Map<String, dynamic>?;
          String roomId = userData?['roomId'] ?? '';

          if (roomId.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.favorite, size: 80, color: Colors.pinkAccent),
                const SizedBox(height: 20),
                const Text("Ruangmu masih sepi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _actionBtn(Icons.add_box_rounded, "Buat Room", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateRoomPage()))),
                  _actionBtn(Icons.qr_code_scanner, "Scan QR", _showScanner),
                  _actionBtn(Icons.vpn_key, "Join Kode", _showJoinDialog),
                ]),
              ]),
            );
          }
          return const Center(child: Text("Halaman Room Utama"));
        },
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return Column(children: [
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
          child: Icon(icon, color: Colors.pinkAccent, size: 30),
        ),
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.pinkAccent))
    ]);
  }

  // ==============================
  // FIX: SCANNER MODAL SETENGAH LAYAR
  // ==============================
  void _showScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Agar rounded terlihat
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5, // Setengah Layar
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: Stack(
            children: [
              MobileScanner(
                controller: MobileScannerController(
                  facing: CameraFacing.back,
                  torchEnabled: false,
                ),
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                    final String code = barcodes.first.rawValue!;
                    Navigator.pop(context);
                    _processJoin(code);
                  }
                },
              ),
              // Overlay Bingkai (UI Pink)
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.pinkAccent, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Positioned(
                top: 15,
                left: 0,
                right: 0,
                child: Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showJoinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Gabung Room"),
        content: TextField(
          controller: _codeController,
          maxLength: 6,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(hintText: "KODE6"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _processJoin(_codeController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
              child: const Text("Gabung", style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}