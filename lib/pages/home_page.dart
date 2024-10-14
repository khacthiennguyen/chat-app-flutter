import 'package:chatapp/components/my_alert_dialog.dart';
import 'package:chatapp/components/my_drawer.dart';
import 'package:chatapp/pages/Chat/chat_room.dart';
import 'package:chatapp/pages/Chat/group_chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
  }

  void setStatus(String status) async {
    await _firebaseFirestore
        .collection("users")
        .doc(_firebaseAuth.currentUser!.uid)
        .update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
//online
      setStatus("Online");
    } else {
      //offline
      setStatus("Offline");
    }
  }

  Map<String, dynamic>? userMap;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _emailUserController = TextEditingController();
  bool _isLoading = false;

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  // Tìm kiếm người dùng theo email
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

  // Hiển thị hộp thoại cảnh báo
  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => MyAlertDialog(text: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.amber,
      ),
      drawer: MyDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSearchContent(),
      floatingActionButton: _buildGroupButton(),
    );
  }

  Widget _buildGroupButton() {
    return FloatingActionButton(
      shape: CircleBorder(),
      onPressed: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => GroupChatPage())),
      backgroundColor: Colors.amber,
      child:  Icon(
        Icons.group,
      ),
      elevation: 10,
    );
  }

  // Nội dung tìm kiếm
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
            _buildUserTile(),
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

  // Nút tìm kiếm
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

  // Hiển thị thông tin người dùng tìm thấy
  Widget _buildUserTile() {
    if (userMap == null) return Container();

    return ListTile(
      onTap: () {
        String roomId = chatRoomId(
            _firebaseAuth.currentUser!.email!, userMap!['userEmail']);

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatRoom(
                    chatRoomId: roomId,
                    userMap: userMap!,
                  )),
        );
      },
      leading:
          const Icon(Icons.account_box, color: Color.fromARGB(255, 40, 39, 38)),
      title: Text(userMap!["userName"],
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
      subtitle: Text(userMap!["userEmail"]),
      trailing: const Icon(Icons.chat, color: Color.fromARGB(255, 73, 70, 61)),
    );
  }
}
