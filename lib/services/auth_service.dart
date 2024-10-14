
import 'package:chatapp/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreServices _firestoreServices = FirestoreServices();

//google signin
  void signInwithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User user = userCredential.user!;
      //print(user);

      _firestoreServices.addUser(user.displayName!, user.email!, user.uid);


      


    }

    // Đăng nhập ok
    catch (error) {
      print("Error signing in with Google: $error");
      // error
    }
  }
}
