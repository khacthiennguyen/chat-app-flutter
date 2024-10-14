import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatelessWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  ChatRoom({super.key, required this.chatRoomId, required this.userMap});

  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  File? _imageFile;

  // Chọn ảnh từ thư viện
  Future<void> _getImage() async {
    final ImagePicker imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      _sendMessage(); // Gửi tin nhắn ngay sau khi chọn hình ảnh
    }
  }

  // Tải ảnh lên Firebase Storage
  Future<String> _uploadImage() async {
    String fileName = Uuid().v1();
    var ref = FirebaseStorage.instance.ref().child("images/$fileName.jpg");
    await ref.putFile(_imageFile!);
    return await ref.getDownloadURL();
  }

  // Gửi tin nhắn
  void _sendMessage() async {
    if (_messageController.text.isNotEmpty || _imageFile != null) {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage(); // Tải ảnh lên và lấy URL
      }

      Map<String, dynamic> messageData = {
        "sendBy": _auth.currentUser!.email,
        "message":
            _messageController.text.isNotEmpty ? _messageController.text : null,
        "imageUrl": imageUrl,
        "time": FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection("chatroom")
          .doc(chatRoomId)
          .collection("chats")
          .add(messageData);

      _messageController.clear();
      _imageFile = null; // Đặt _imageFile về null sau khi gửi
      _scrollToBottom(); // Cuộn xuống tin nhắn cuối cùng
    } else {
      print("Enter some text or select an image...");
    }
  }

  // Cuộn xuống tin nhắn cuối cùng
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Hiển thị hình ảnh
  void _showImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Image.network(imageUrl),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream:
              _firestore.collection("users").doc(userMap['uid']).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.exists) {
              var userStatus = snapshot.data!.get("status");
              return Column(
                children: [
                  Text(userMap['userName']),
                  Text(userStatus, style: const TextStyle(fontSize: 14)),
                ],
              );
            } else {
              return Container();
            }
          },
        ),
        backgroundColor: Colors.amber,
      ),
      body: SizedBox(
        height: size.height,
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection("chatroom")
              .doc(chatRoomId)
              .collection("chats")
              .orderBy("time", descending: false)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom(); // Cuộn xuống mỗi khi có dữ liệu mới
              });

              return ListView.builder(
                controller: _scrollController,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> map =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return _messageWidget(size, map, context);
                },
              );
            } else {
              return Container();
            }
          },
        ),
      ),
      bottomNavigationBar: _buildMessageInput(size),
    );
  }

  // UI - Entern Message
  Widget _buildMessageInput(Size size) {
    return Container(
      height: size.height / 10,
      width: size.width,
      alignment: Alignment.center,
      child: SizedBox(
        height: size.height / 12,
        width: size.width / 1.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: _getImage,
                    icon: const Icon(Icons.photo),
                  ),
                  hintText: "Send Message",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  // UI message
  Widget _messageWidget(
      Size size, Map<String, dynamic> map, BuildContext context) {
    return Container(
      width: size.width,
      alignment: map['sendBy'] == _auth.currentUser!.email
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: size.width),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: map['sendBy'] == _auth.currentUser!.email
              ? Colors.green
              : Colors.blue,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (map['imageUrl'] != null)
              _buildImageMessage(map['imageUrl'], context),
            Container(
              constraints: const BoxConstraints(maxWidth: 250),
              child: Text(
                map['message'] ?? "",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageMessage(String imageUrl, BuildContext context) {
    return GestureDetector(
      onTap: () => _showImage(context, imageUrl),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
