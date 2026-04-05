import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../settings_page.dart'; // Import halaman settings

class DashboardPage extends StatelessWidget {
  final String roomId;
  const DashboardPage({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('rooms').doc(roomId).snapshots(),
      builder: (context, roomSnap) {
        if (!roomSnap.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
        }

        var roomData = roomSnap.data!.data() as Map<String, dynamic>;
        List<dynamic> members = roomData['members'] ?? [];
        String? partnerUid = members.firstWhere((uid) => uid != currentUid, orElse: () => null);

        // Ambil Nama Panggilan dari Room
        String panggilPria = roomData['panggilanPria'] ?? 'Pria';
        String panggilWanita = roomData['panggilanWanita'] ?? 'Wanita';

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId, whereIn: members.isNotEmpty ? members : ['dummy'])
              .snapshots(),
          builder: (context, userSnap) {
            if (!userSnap.hasData) return const SizedBox();

            var users = userSnap.data!.docs;

            // Data Saya
            var meDoc = users.firstWhere((d) => d.id == currentUid);
            var meData = meDoc.data() as Map<String, dynamic>;
            String myRealName = meData['name'] ?? 'User';
            // Logika: Jika saya adalah member pertama (index 0), saya Pria, jika bukan saya Wanita
            String myNickname = (currentUid == members[0]) ? panggilPria : panggilWanita;

            // Data Pasangan
            var partnerDoc = users.any((d) => d.id == partnerUid)
                ? users.firstWhere((d) => d.id == partnerUid)
                : null;

            String partnerRealName = 'Waiting...';
            String? partnerPhoto;
            String partnerNickname = (partnerUid == members[0]) ? panggilPria : panggilWanita;
            Map<String, dynamic>? partnerFullData;

            if (partnerDoc != null) {
              partnerFullData = partnerDoc.data() as Map<String, dynamic>;
              partnerRealName = partnerFullData['name'] ?? 'Partner';
              partnerPhoto = partnerFullData['photoUrl'];
            }

            // Hitung Hari Anniversary
            DateTime? anniv = (roomData['anniversaryDate'] as Timestamp?)?.toDate();
            int days = anniv != null ? DateTime.now().difference(anniv).inDays : 0;

            return Scaffold(
              backgroundColor: const Color(0xFFFFF0F3),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.pinkAccent),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      );
                    },
                  ),
                ],
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Text(
                      roomData['roomName'] ?? "Love Space",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink[800]),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Sisi Saya
                        GestureDetector(
                          onTap: () => _showProfileInfo(context, meData, myNickname),
                          child: _profileCircle("$myRealName ($myNickname)", meData['photoUrl']),
                        ),
                        const Icon(Icons.favorite, color: Colors.pinkAccent, size: 45),
                        // Sisi Pasangan
                        GestureDetector(
                          onTap: partnerFullData != null
                              ? () => _showProfileInfo(context, partnerFullData!, partnerNickname)
                              : null,
                          child: _profileCircle(
                              partnerDoc != null ? "$partnerRealName ($partnerNickname)" : "Waiting...",
                              partnerPhoto
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text("Sudah Bersama Selama", style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 10),
                          Text(
                            "$days Hari",
                            style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                          ),
                          const Divider(height: 30),
                          Text(
                            anniv != null ? DateFormat('dd MMMM yyyy').format(anniv) : "Tanggal belum diatur",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _profileCircle(String label, String? url) {
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 42,
            backgroundColor: Colors.pink[50],
            backgroundImage: (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
            child: (url == null || url.isEmpty) ? const Icon(Icons.person, size: 40, color: Colors.pinkAccent) : null,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
        ),
      ],
    );
  }

  void _showProfileInfo(BuildContext context, Map<String, dynamic> data, String nickname) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: (data['photoUrl'] != null && data['photoUrl'] != '') ? NetworkImage(data['photoUrl']) : null,
              child: (data['photoUrl'] == null || data['photoUrl'] == '') ? const Icon(Icons.person, size: 50) : null,
            ),
            const SizedBox(height: 15),
            Text(data['name'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text("($nickname)", style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Text(data['email'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}