import 'dart:io';
import 'package:chatapp/pages/Chat/group_info.dart';
import 'package:chatapp/services/firestore_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class GroupChatRoom extends StatelessWidget {
  final String groupChatId, groupName;
  GroupChatRoom(
      {super.key, required this.groupChatId, required this.groupName});

  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  final FirestoreServices _firestoreServices = FirestoreServices();

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
      onSendMessage(); // Gửi tin nhắn ngay sau khi chọn hình ảnh
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
  void onSendMessage() async {
    // get usrName current
    var infoCurrentUser =
        await _firestoreServices.getUserByUid(_auth.currentUser!.uid);
    String currentUserName = infoCurrentUser['userName'];

    if (_messageController.text.isNotEmpty || _imageFile != null) {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage(); // Tải ảnh lên và lấy URL
      }

      Map<String, dynamic> chatData = {
        "nameUserSend": currentUserName,
        "sendBy": _auth.currentUser!.email,
        "message":
            _messageController.text.isNotEmpty ? _messageController.text : null,
        "imageUrl": imageUrl,
        "type": imageUrl != null ? "img" : "text",
        "time": FieldValue.serverTimestamp(),
      };

      _messageController.clear();
      _imageFile = null; // Đặt _imageFile về null sau khi gửi
      await _firebaseFirestore
          .collection("groupchats")
          .doc(groupChatId)
          .collection("chats")
          .add(chatData);

      _scrollToBottom(); // Cuộn xuống tin nhắn cuối cùng
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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GroupInfo(
                        groupId: groupChatId,
                        groupName: groupName,
                      ),
                    ),
                  ),
              icon: Icon(Icons.more_vert))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: _firebaseFirestore
                    .collection("groupchats")
                    .doc(groupChatId)
                    .collection("chats")
                    .orderBy("time")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom(); // Cuộn xuống mỗi khi có dữ liệu mới
                    });

                    return ListView.builder(
                        controller: _scrollController,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> chatMap =
                              snapshot.data?.docs[index].data()
                                  as Map<String, dynamic>;
                          return _buildMessageTile(size, chatMap, context);
                        });
                  } else {
                    return Container();
                  }
                }),
          ),
          _buildMessageInput(size),
        ],
      ),
    );
  }

  Widget _buildMessageTile(
      Size size, Map<String, dynamic> chatMap, BuildContext context) {
    if (chatMap['type'] == "text") {
      return Container(
        alignment: chatMap['sendBy'] == _auth.currentUser!.email
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                child: Text(
                  chatMap['nameUserSend'],
                  style: TextStyle(
                      color: const Color.fromARGB(223, 0, 0, 0),
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: size.height / 200),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.green,
                ),
                child: Text(
                  chatMap['message'],
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
    } else if (chatMap['type'] == 'img') {
      return Container(
        child: GestureDetector(
          onTap: () => _showImage(context, chatMap['imageUrl']),
          child: Column(
            crossAxisAlignment: chatMap['sendBy'] == _auth.currentUser!.email
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                child: Text(
                  chatMap['nameUserSend'],
                  style: TextStyle(
                      color: const Color.fromARGB(223, 0, 0, 0),
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                constraints: BoxConstraints(maxWidth: 250),
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                alignment: chatMap['sendBy'] == _auth.currentUser!.email
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Image.network(chatMap['imageUrl']),
              ),
            ],
          ),
        ),
      );
    } else if ((chatMap['type'] == 'notify')) {
      return Container(
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.black38,
          ),
          child: Column(
            children: [
              // SizedBox(height: size.height / 200),
              Text(
                chatMap['message'],
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox(); // Đảm bảo phương thức luôn trả về Widget
    }
  }

  // UI Enter Message
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
              onPressed: onSendMessage,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
