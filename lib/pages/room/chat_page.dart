import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPage extends StatefulWidget {
  final String roomId;
  const ChatPage({super.key, required this.roomId});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _msgController = TextEditingController();
  final userId = FirebaseAuth.instance.currentUser?.uid;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  final String cloudName = "dubjinrem";
  final String uploadPreset = "fileChat";

  void _onTyping(String val) {
    if (userId == null) return;
    FirebaseFirestore.instance.collection('rooms').doc(widget.roomId).update({
      'typing_$userId': val.isNotEmpty,
    });
  }

  Future<void> _handleUpload(ImageSource source, {String type = 'image'}) async {
    final XFile? pickedFile = type == 'video'
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(source: source);

    if (pickedFile == null) return;
    setState(() => _isUploading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload'),
      );
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));

      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      var jsonRes = jsonDecode(responseString);

      if (response.statusCode == 200) {
        _sendMsg(text: "[${type.toUpperCase()}]", fileUrl: jsonRes['secure_url'], type: type);
      }
    } catch (e) {
      debugPrint("Upload Error: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _sendMsg({String? text, String? fileUrl, String type = 'text'}) {
    String msgText = text ?? _msgController.text.trim();
    if (msgText.isEmpty && fileUrl == null) return;

    FirebaseFirestore.instance.collection('rooms').doc(widget.roomId).collection('chats').add({
      'senderId': userId,
      'text': msgText,
      'fileUrl': fileUrl ?? '',
      'type': type,
      'time': FieldValue.serverTimestamp(),
      'read': false,
    });
    _msgController.clear();
    _onTyping("");
  }

  void _showAttachMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          children: [
            _attachBtn(Icons.image, "Galeri", Colors.purple, () => _handleUpload(ImageSource.gallery)),
            _attachBtn(Icons.camera_alt, "Kamera", Colors.pink, () => _handleUpload(ImageSource.camera)),
            _attachBtn(Icons.videocam, "Video", Colors.orange, () => _handleUpload(ImageSource.gallery, type: 'video')),
            _attachBtn(Icons.sticky_note_2, "Sticker", Colors.blue, () => _handleUpload(ImageSource.gallery, type: 'sticker')),
            _attachBtn(Icons.insert_drive_file, "Dokumen", Colors.indigo, () {}),
            _attachBtn(Icons.location_on, "Lokasi", Colors.green, () {}),
          ],
        ),
      ),
    );
  }

  Widget _attachBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () { Navigator.pop(context); onTap(); },
      child: Column(children: [
        CircleAvatar(radius: 28, backgroundColor: color, child: Icon(icon, color: Colors.white)),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12))
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false, // Menghapus tombol back yang bikin black screen
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('rooms').doc(widget.roomId).snapshots(),
          builder: (context, snap) {
            bool isPartnerTyping = false;
            if (snap.hasData && snap.data != null && snap.data!.exists) {
              var data = snap.data!.data() as Map<String, dynamic>? ?? {};
              data.forEach((key, value) {
                if (key.startsWith('typing_') && key != 'typing_$userId') {
                  isPartnerTyping = value == true;
                }
              });
            }
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Private Chat", style: TextStyle(color: Colors.pinkAccent, fontSize: 16, fontWeight: FontWeight.bold)),
              if (isPartnerTyping) const Text("sedang mengetik...", style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
            ]);
          },
        ),
      ),
      body: Column(children: [
        if (_isUploading) const LinearProgressIndicator(color: Colors.pinkAccent, backgroundColor: Colors.white),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('rooms').doc(widget.roomId).collection('chats').orderBy('time', descending: true).snapshots(),
            builder: (context, snap) {
              if (snap.hasError) return const Center(child: Text("Terjadi kesalahan data"));
              if (!snap.hasData) return const SizedBox();

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: snap.data!.docs.length,
                itemBuilder: (context, i) {
                  var chat = snap.data!.docs[i];
                  bool isMe = chat['senderId'] == userId;

                  // Tandai sudah dibaca secara aman
                  if (!isMe && (chat.data() as Map<String, dynamic>).containsKey('read') && chat['read'] == false) {
                    chat.reference.update({'read': true});
                  }

                  return _buildMessage(chat, isMe);
                },
              );
            },
          ),
        ),
        _chatInput(),
      ]),
    );
  }

  Widget _buildMessage(DocumentSnapshot doc, bool isMe) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    String time = '';
    if (data['time'] != null && data['time'] is Timestamp) {
      time = DateFormat('HH:mm').format((data['time'] as Timestamp).toDate());
    }

    final String type = data['type']?.toString() ?? 'text';
    final String text = data['text']?.toString() ?? '';
    final String fileUrl = data['fileUrl']?.toString() ?? '';
    final String senderId = data['senderId']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && senderId.isNotEmpty)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(senderId).snapshots(),
              builder: (context, userSnap) {
                String? photoUrl;
                if (userSnap.hasData && userSnap.data != null && userSnap.data!.exists) {
                  var userData = userSnap.data!.data() as Map<String, dynamic>?;
                  photoUrl = userData?['photoUrl'];
                }
                return CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.pink[100],
                  backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                  child: (photoUrl == null || photoUrl.isEmpty) ? const Icon(Icons.person, size: 18, color: Colors.white) : null,
                );
              },
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? Colors.pinkAccent : Colors.white,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: isMe ? Radius.zero : const Radius.circular(18),
                  bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if ((type == 'image' || type == 'sticker') && fileUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        fileUrl,
                        width: type == 'sticker' ? 120 : 200,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                      ),
                    )
                  else if (type == 'video' && fileUrl.isNotEmpty)
                    const Icon(Icons.play_circle_fill, size: 50, color: Colors.white)
                  else
                    Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),

                  const SizedBox(height: 4),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(time, style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.grey)),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.done_all, size: 14, color: data['read'] == true ? Colors.blue : Colors.white70),
                    ]
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.white,
      child: Row(children: [
        IconButton(icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey), onPressed: () {}),
        Expanded(
          child: TextField(
            controller: _msgController,
            onChanged: _onTyping,
            decoration: InputDecoration(
                hintText: "Ketik pesan...",
                filled: true,
                fillColor: Colors.pink[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20)
            ),
          ),
        ),
        IconButton(icon: const Icon(Icons.attach_file, color: Colors.pinkAccent), onPressed: _showAttachMenu),
        CircleAvatar(
          backgroundColor: Colors.pinkAccent,
          child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => _sendMsg()
          ),
        ),
      ]),
    );
  }
}