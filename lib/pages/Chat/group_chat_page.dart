import 'package:chatapp/pages/Chat/cretate_group/add_member.dart';
import 'package:chatapp/pages/Chat/group_chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupChatPage extends StatefulWidget {
  const GroupChatPage({super.key});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;

  List groupList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAvailableGroup();
  }

  void getAvailableGroup() async {
    String uid = _auth.currentUser!.uid;
    await _firebaseFirestore
        .collection("users")
        .doc(uid)
        .collection("groupchats")
        .get()
        .then((groupListData) {
      setState(() {
        groupList = groupListData.docs;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Group"),
        backgroundColor: Colors.amber,
      ),
      body: isLoading
          ? Container(
              height: size.height / 12,
              width: size.width / 12,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: groupList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => GroupChatRoom(
                        groupName: groupList[index]['groupName'],
                            groupChatId: groupList[index]['id'],
                          ))),
                  leading: Icon(Icons.group),
                  title: Text(groupList[index]["groupName"]),
                );
              }),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AddMemberInGroup())),
        backgroundColor: Colors.amber,
        child: Icon(
          Icons.add,
        ),
        elevation: 10,
      ),
    );
  }
}
