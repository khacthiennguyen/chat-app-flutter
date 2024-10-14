import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  //get id document 
  Future<DocumentSnapshot> getUserByUid(String uid) async {
    // Truy cập vào document bằng UID
    return await _firebaseFirestore.collection("users").doc(uid).get();
  }

  // Thêm người dùng vào Firestore với UID là khóa chính
  Future<void> addUser(String userName, String userEmail, String uid) {
    // Tham chiếu đến tài liệu người dùng với UID
    final DocumentReference userRef =
        _firebaseFirestore.collection("users").doc(uid);

    return userRef.set({
      'userName': userName,
      'userEmail': userEmail,
      'password': "dsbfhajksdfhadsflkajdsfhadsjfhkl",
      'status': 'Uknow',
      'uid': uid
    });
  }


  // Cập nhật trạng thái của người dùng
  Future<void> updateUserStatus(String uid, String status) async {
    try {
      await _firebaseFirestore.collection("users").doc(uid).update({
        "status": status,
      });
    } catch (error) {
      print("Error updating user status: $error");
    }
  
}



}
