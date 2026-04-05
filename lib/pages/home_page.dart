import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'settings_page.dart';
import 'room/create_room_page.dart';
import 'room/dashboard_page.dart';
import 'room/chat_page.dart';
import 'room/moments_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _codeController = TextEditingController();
  bool _isProcessing = false;
  int _selectedIndex = 0;

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
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // DEAL: StreamBuilder dipasang, tapi UI di dalamnya tetap 100% milikmu
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.pinkAccent)));
        }

        var userData = snapshot.data?.data() as Map<String, dynamic>?;
        String roomId = userData?['roomId'] ?? '';

        // TAMPILAN JIKA BELUM ADA ROOM (Sesuai kode asli kamu)
        if (roomId.isEmpty) {
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
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite, size: 80, color: Colors.pinkAccent),
                  const SizedBox(height: 20),
                  const Text("Ruangmu masih sepi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionBtn(Icons.add_box_rounded, "Buat Room", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateRoomPage()))),
                      _actionBtn(Icons.qr_code_scanner, "Scan QR", _showScanner),
                      _actionBtn(Icons.vpn_key, "Join Kode", _showJoinDialog),
                    ],
                  )
                ],
              ),
            ),
          );
        }

        // TAMPILAN JIKA SUDAH ADA ROOM
        final List<Widget> _pages = [
          DashboardPage(roomId: roomId),
          ChatPage(roomId: roomId),
          MomentsPage(roomId: roomId),
        ];

        return Scaffold(
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            selectedItemColor: Colors.pinkAccent,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
              BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: 'Moments'),
            ],
          ),
        );
      },
    );
  }

  // --- SEMUA FUNGSI UI DI BAWAH INI TETAP UTUH SESUAI FILE ASLIMU ---
  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Icon(icon, color: Colors.pinkAccent, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.pinkAccent))
      ],
    );
  }

  void _showScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              child: MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                    Navigator.pop(context);
                    _processJoin(barcodes.first.rawValue!);
                  }
                },
              ),
            ),
            // Dekorasi garis di atas bottomsheet
            Positioned(
              top: 15,
              left: 0,
              right: 0,
              child: Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              ),
            )
          ],
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
            child: const Text("Gabung", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}