import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'edit_profile_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _handleRefresh() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      setState(() {});
    }
  }

  Future<void> _leaveRoom(String roomId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
        'members': FieldValue.arrayRemove([user.uid])
      });
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'roomId': ''});
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Gagal keluar: $e");
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
        title: const Text("Pengaturan", style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.pinkAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.pinkAccent,
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
          builder: (context, userSnap) {
            if (!userSnap.hasData) return const Center(child: CircularProgressIndicator());
            var userData = userSnap.data!.data() as Map<String, dynamic>?;
            String name = userData?['name'] ?? "User Love Space";
            String email = user?.email ?? "";
            String photoUrl = userData?['photoUrl'] ?? "";
            String currentRoomId = userData?['roomId'] ?? "";

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildProfileCard(name, email, photoUrl),
                const SizedBox(height: 25),
                _buildSectionTitle("Ruangan Kamu"),
                currentRoomId.isEmpty
                    ? _buildEmptyRoomCard()
                    : _buildRoomManagementCard(currentRoomId),
                const SizedBox(height: 25),
                _buildSectionTitle("Akun & Aplikasi"),
                _buildMenuBox([
                  _buildMenuItem(Icons.person_outline, "Edit Profil", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfilePage(currentName: name, currentPhoto: photoUrl)));
                  }),
                  _buildMenuItem(Icons.logout_rounded, "Keluar Akun", _showExitDialog, isLogout: true),
                ]),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoomManagementCard(String roomId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('rooms').doc(roomId).snapshots(),
      builder: (context, roomSnap) {
        if (!roomSnap.hasData || !roomSnap.data!.exists) return const SizedBox();
        var roomData = roomSnap.data!.data() as Map<String, dynamic>;
        String roomCode = roomData['roomCode'] ?? "";

        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.pinkAccent),
                title: Text(roomData['roomName'] ?? "Room", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Kode: $roomCode"),
                trailing: IconButton(
                  icon: const Icon(Icons.qr_code_2_rounded, color: Colors.pinkAccent, size: 30),
                  onPressed: () => _showQrCode(roomCode),
                ),
              ),
              const Divider(),
              TextButton.icon(
                onPressed: () => _leaveRoom(roomId),
                icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                label: const Text("Keluar dari Room", style: TextStyle(color: Colors.redAccent)),
              )
            ],
          ),
        );
      },
    );
  }

  // ==============================
  // FIX: QR CODE DENGAN FIXED SIZE
  // ==============================
  void _showQrCode(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("QR Room", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // WAJIB: Gunakan SizedBox agar ukurannya terbaca oleh LayoutBuilder
            SizedBox(
              width: 220,
              height: 220,
              child: QrImageView(
                data: code,
                version: QrVersions.auto,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: Colors.pinkAccent),
                dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Colors.pinkAccent),
              ),
            ),
            const SizedBox(height: 20),
            Text(code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 5)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup")),
        ],
      ),
    );
  }

  Widget _buildEmptyRoomCard() => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: const Text("Belum ada room aktif."));

  Widget _buildProfileCard(String name, String email, String photoUrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Row(children: [
        CircleAvatar(radius: 30, backgroundColor: Colors.pink[50], backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null, child: photoUrl.isEmpty ? const Icon(Icons.person, color: Colors.pinkAccent) : null),
        const SizedBox(width: 15),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
      ]),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(padding: const EdgeInsets.only(left: 10, bottom: 10), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)));

  Widget _buildMenuBox(List<Widget> items) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(children: items));

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(leading: Icon(icon, color: isLogout ? Colors.redAccent : Colors.pinkAccent), title: Text(title, style: TextStyle(color: isLogout ? Colors.redAccent : Colors.black87)), onTap: onTap);
  }

  void _showExitDialog() {
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text("Keluar"), content: const Text("Yakin ingin logout?"), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")), TextButton(onPressed: () async { await FirebaseAuth.instance.signOut(); Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false); }, child: const Text("Keluar", style: TextStyle(color: Colors.red)))]));
  }
}