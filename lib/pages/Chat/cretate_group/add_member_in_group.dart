import 'package:chatapp/components/my_alert_dialog.dart';
import 'package:chatapp/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddMoreMemberInGroup extends StatefulWidget {
  final String groupName, groupId;
  final List memberList;
  AddMoreMemberInGroup(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.memberList});

  @override
  State<AddMoreMemberInGroup> createState() => _AddMoreMemberInGroup();
}

class _AddMoreMemberInGroup extends State<AddMoreMemberInGroup> {
  final TextEditingController _emailUserController = TextEditingController();
  bool _isLoading = false;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List membersList = [];
  Map<String, dynamic>? userMap;

  @override
  void initState() {
    super.initState();
    //getCurrentUserDetails();
    membersList = widget.memberList;
  }

  // void getCurrentUserDetails() async {
  //   await _firebaseFirestore
  //       .collection("users")
  //       .doc(_auth.currentUser!.uid)
  //       .get()
  //       .then((map) {
  //     setState(() {
  //       membersList.add({
  //         "userName": map['userName'],
  //         "userEmail": map["userEmail"],
  //         "uid": map['uid'],
  //         "isAdmin": true,
  //       });
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add members"),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSearchContent(size),
            if (userMap != null) _buildUserTile(),
          ],
        ),
      ),
     
    );
  }

  Widget _buildSearchContent(Size size) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildSearchField(),
            const SizedBox(height: 12),
            _isLoading
                ? Container(
                    height: size.height / 12,
                    width: size.width / 12,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )
                : _buildSearchButton(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        controller: _emailUserController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          hintText: "Enter email to search",
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton(
      onPressed: _onSearchUserEmail,
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
          Icon(Icons.search),
          SizedBox(width: 8),
          Text("Search",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _onSearchUserEmail() async {
    setState(() => _isLoading = true);
    try {
      final querySnapshot = await _firebaseFirestore
          .collection("users")
          .where("userEmail", isEqualTo: _emailUserController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          userMap = querySnapshot.docs[0].data();
        });
        _emailUserController.clear();
      } else {
        setState(() {
          userMap = null;
        });
        _showAlertDialog("No user found.");
      }
    } catch (e) {
      _showAlertDialog("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => MyAlertDialog(text: message),
    );
  }

  Widget _buildUserTile() {
    return ListTile(
      tileColor: Colors.grey[200],
      title: Text(userMap!['userName']),
      subtitle: Text(userMap!['userEmail']),
      leading: Icon(Icons.account_circle, color: Colors.grey),
      onTap: onAddMembers,
    );
  }

  void onAddMembers() async {
    membersList.add({
      "userName": userMap!['userName'],
      "userEmail": userMap!["userEmail"],
      "uid": userMap!['uid'],
      "isAdmin": false,
    });

    await _firebaseFirestore
        .collection("groupchats")
        .doc(widget.groupId)
        .update({
      "members": membersList,
    });

    await _firebaseFirestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("groupchats")
        .doc(widget.groupId)
        .set({
      "groupName": widget.groupName,
      "id": widget.groupId,
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePage()), (route) => false);
  }

  

}
