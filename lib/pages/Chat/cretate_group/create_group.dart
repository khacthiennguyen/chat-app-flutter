import 'package:chatapp/pages/home_page.dart';
import 'package:chatapp/services/firestore_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CreateGroup extends StatefulWidget {
  final List<Map<String, dynamic>> memberList;
  CreateGroup({super.key, required this.memberList});

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final TextEditingController _groupName = TextEditingController();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreServices _firestoreServices = FirestoreServices();
  bool isLoading = false;

  void createGroup() async {
    setState(() {
      isLoading = true;
    });

    String groupId = Uuid().v1();
    var infoCurrentUser =
        await _firestoreServices.getUserByUid(_auth.currentUser!.uid);
    String currentUserName = infoCurrentUser['userName'];

    await _firebaseFirestore.collection("groupchats").doc(groupId).set({
      "members": widget.memberList,
      "id": groupId,
    });

    for (int i = 0; i < widget.memberList.length; i++) {
      String uid = widget.memberList[i]['uid'];

      await _firebaseFirestore
          .collection("users")
          .doc(uid)
          .collection("groupchats")
          .doc(groupId)
          .set({
        "groupName": _groupName.text,
        "id": groupId,
      });
    }

    await _firebaseFirestore
        .collection("groupchats")
        .doc(groupId)
        .collection("chats")
        .add({
      "message": "${currentUserName} Create this group",
      "type": "notify",
      "time": FieldValue.serverTimestamp(),
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("group name"),
        backgroundColor: Colors.amber,
      ),
      body: isLoading
          ? Container(
              height: size.height / 12,
              width: size.width / 12,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                _buildSearchContent(),
                // SizedBox(
                //   height: size.height / 10,
                // )
              ],
            ),
    );
  }

  Widget _buildSearchContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildSearchField(),
            const SizedBox(height: 12),
            _buildSearchButton(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Trường tìm kiếm
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        controller: _groupName,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          hintText: "Enter Group Name",
        ),
      ),
    );
  }

  // Nút tìm kiếm
  Widget _buildSearchButton() {
    return ElevatedButton(
      onPressed: () => createGroup(),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        backgroundColor: const Color.fromARGB(255, 134, 159, 65),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.create),
          SizedBox(width: 8),
          Text("Create Group",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
