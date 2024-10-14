
import 'package:chatapp/pages/Chat/cretate_group/add_member_in_group.dart';
import 'package:chatapp/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final String groupName, groupId;
  GroupInfo({super.key, required this.groupId, required this.groupName});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List memberList = [];
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGroupMember();
  }

  bool checkAdmin() {
    bool isAdmin = false;
    memberList.forEach((element) {
      if (element['uid'] == _auth.currentUser!.uid) {
        isAdmin = element['isAdmin'];
      }
    });
    return isAdmin;
  }

  void getGroupMember() async {
    await _firebaseFirestore
        .collection("groupchats")
        .doc(widget.groupId)
        .get()
        .then((value) {
      setState(() {
        memberList = value['members'];
        isLoading = false;
      });
    });
  }

  void showRemoveDialog(int index, String name) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: ListTile(
              onTap: () => removeUser(index),
              title: Text(
                "Remove ${name} ?  Click to continue",
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        });
  }

  void removeUser(int index) async {
    if (checkAdmin()) {
      if (_auth.currentUser!.uid != memberList[index]['uid']) {
        setState(() {
          isLoading = true;
        });
        String uid = memberList[index]['uid'];
        await _firebaseFirestore
            .collection("groupchats")
            .doc(widget.groupId)
            .update({
          "members": memberList,
        });

        setState(() {
          memberList.removeAt(index); // Xóa người dùng khỏi danh sách
        });

        await _firebaseFirestore
            .collection("users")
            .doc(uid)
            .collection("groupchats")
            .doc(widget.groupId)
            .delete();

        setState(() {
          isLoading = false;
        });
      }
    } else {
      print("cant remove");
    }
  }

  void leaveGroup() async {
    if (!checkAdmin()) {
      setState(() {
        isLoading = true;
      });
      String uid = _auth.currentUser!.uid;

      for (int i = 0; i < memberList.length; i++) {
        if (memberList[i]['uid'] == uid) {
          memberList.removeAt(i);
        }
      }

      await _firebaseFirestore
          .collection("groupchats")
          .doc(widget.groupId)
          .update({
        "members": memberList,
      });

      await _firebaseFirestore
          .collection("users")
          .doc(uid)
          .collection("groupchats")
          .doc(widget.groupId)
          .delete();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false);
    } else {
      print("cant left group");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? Container(
                height: size.height / 12,
                width: size.width / 12,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(alignment: Alignment.centerLeft, child: BackButton()),
                    Container(
                      height: size.height / 8,
                      width: size.width / 1.1,
                      child: Row(
                        children: [
                          Container(
                            height: size.height / 11,
                            width: size.height / 11,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: Icon(
                              Icons.group,
                              color: Colors.white,
                              size: size.width / 10,
                            ),
                          ),
                          SizedBox(
                            width: size.width / 20,
                          ),
                          Expanded(
                              child: Text(
                            widget.groupName,
                            style: TextStyle(
                                fontSize: size.width / 16,
                                fontWeight: FontWeight.w500),
                          )),
                        ],
                      ),
                    ),

                    //

                    SizedBox(
                      height: size.height / 30,
                    ),
                    Container(
                      width: size.width / 1.1,
                      child: Text(
                        "${memberList.length} Members",
                        style: TextStyle(
                            fontSize: size.width / 20,
                            fontWeight: FontWeight.w500),
                      ),
                    ),

                    SizedBox(
                      height: size.height / 70,
                    ),

                    ListTile(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AddMoreMemberInGroup(
                                groupId: widget.groupId,
                                groupName: widget.groupName,
                                memberList: memberList,
                              ))),
                      leading: Icon(
                        Icons.add,
                        color: Colors.redAccent,
                      ),
                      title: Text(
                        "Add Members",
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: size.width / 22,
                            fontWeight: FontWeight.w500),
                      ),
                    ),

                    //Member name
                    Flexible(
                        child: ListView.builder(
                            itemCount: memberList.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () => showRemoveDialog(
                                    index, memberList[index]["userName"]),
                                leading: Icon(Icons.account_circle),
                                title: Text(
                                  memberList[index]["userEmail"] ==
                                          _auth.currentUser!.email
                                      ? memberList[index]["userEmail"] +
                                          " (You) "
                                      : memberList[index]["userEmail"],
                                  style: TextStyle(
                                      fontSize: size.width / 22,
                                      fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(memberList[index]["userEmail"]),
                                trailing: memberList[index]["isAdmin"]
                                    ? Text("Admin")
                                    : Icon(
                                        Icons.remove,
                                        color: Colors.red,
                                      ),
                              );
                            })),

                    //

                    // SizedBox(
                    //   height: size.height / 30,
                    // ),

                    ListTile(
                      onTap: leaveGroup,
                      leading: Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: Text(
                        "Leave Group",
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: size.width / 22,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
