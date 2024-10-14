import 'package:chatapp/components/my_alert_dialog.dart';
import 'package:chatapp/pages/Chat/cretate_group/create_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddMemberInGroup extends StatefulWidget {
  AddMemberInGroup({super.key});

  @override
  State<AddMemberInGroup> createState() => _AddMemberInGroupState();
}

class _AddMemberInGroupState extends State<AddMemberInGroup> {
  final TextEditingController _emailUserController = TextEditingController();
  bool _isLoading = false;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> membersList = [];
  Map<String, dynamic>? userMap;

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
    await _firebaseFirestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .get()
        .then((map) {
      setState(() {
        membersList.add({
          "userName": map['userName'],
          "userEmail": map["userEmail"],
          "uid": map['uid'],
          "isAdmin": true,
        });
      });
    });
  }

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
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: membersList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () => onRemoveMember(index),
                    leading: const Icon(Icons.account_circle,
                        color: Color.fromARGB(255, 40, 39, 38)),
                    title: Text(
                        membersList[index]['userEmail'] ==
                                _auth.currentUser!.email
                            ? membersList[index]['userName'] + " (You) "
                            : membersList[index]['userName'],
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w500)),
                    subtitle: Text(membersList[index]['userEmail']),
                    trailing: membersList[index]['userEmail'] !=
                            _auth.currentUser!.email
                        ? const Icon(Icons.close,
                            color: Color.fromARGB(255, 238, 64, 6))
                        : null,
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: membersList.length >= 2
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CreateGroup(memberList: membersList))),
              backgroundColor: Colors.amber,
              shape: CircleBorder(),
              child: Icon(Icons.forward),
            )
          : FloatingActionButton(
              onPressed: () => _showAlertDialog(
                  "Group required 2 member is minimum, please add more !"),
              backgroundColor: Colors.amber,
              shape: CircleBorder(),
              child: Icon(Icons.forward),
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
      onTap: onAddMember,
    );
  }

  void onAddMember() {
    bool isAlreadyExist = false;
    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['uid'] == userMap!['uid']) {
        isAlreadyExist = true;
      }
    }

    if (!isAlreadyExist) {
      setState(() {
        membersList.add({
          "userName": userMap!['userName'],
          "userEmail": userMap!["userEmail"],
          "uid": userMap!['uid'],
          "isAdmin": false,
        });

        userMap = null;
      });
    } else {
      setState(() {
        _showAlertDialog("Member already exists in the group.");
        userMap = null;
      });
      // Hiển thị thông báo khi thành viên đã tồn tại
    }
  }

  void onRemoveMember(int index) {
    if (membersList[index]['uid'] != _auth.currentUser!.uid) {
      setState(() {
        membersList.removeAt(index);
      });
    }
  }
}
