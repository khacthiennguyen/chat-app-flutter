import 'package:chatapp/components/my_button.dart';
import 'package:chatapp/components/my_textfield.dart';
import 'package:chatapp/components/square_tile.dart';
import 'package:chatapp/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ResgisterPage extends StatefulWidget {
  final Function()? onTap;
  ResgisterPage({super.key, required this.onTap});

  @override
  State<ResgisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<ResgisterPage> {
  //text edit controller
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreServices _firestoreServices = FirestoreServices();

//google signin
  Future<void> signInwithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await _auth.signInWithCredential(credential);
      // Đăng nhập ok
    } catch (error) {
      print("Error signing in with Google: $error");
      // error
    }
  }

// sign up wwith email va password
 void signUserUp() async {
  // Hiển thị vòng xoay loading
  showDialog(
    context: context,
    builder: (context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );

  try {
    if (passwordController.text == confirmPasswordController.text) {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = _auth.currentUser;
      String uid = user!.uid;

      await _firestoreServices.addUser(
          userNameController.text, emailController.text, uid);

      if (mounted) Navigator.pop(context); // Đóng loading dialog
    } else {
      if (mounted) Navigator.pop(context);
      messengerPopup("Passwords don't match!");
      return; // Dừng hàm tại đây
    }
  } on FirebaseAuthException catch (e) {
    if (mounted) Navigator.pop(context);
    messengerPopup(e.code == 'email-already-in-use'
        ? "Email is already in use!"
        : e.code);
  }
}

  void messengerPopup(String messengerCode) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            messengerCode == 'wrong-password'
                ? 'Password Error'
                : messengerCode == 'invalid-credential'
                    ? 'User Not Found'
                    : messengerCode == 'invalid-email'
                        ? 'Invalid Email'
                        : messengerCode,
            style: TextStyle(fontSize: 16),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 25,
                ),
                const Icon(
                  Icons.lock,
                  size: 50,
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  "Let's Create An Account For You",
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                const SizedBox(
                  height: 25,
                ),
                MyTextfield(
                  controller: userNameController,
                  hintText: "Name",
                  obscureText: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                MyTextfield(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                MyTextfield(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                MyTextfield(
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  obscureText: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 25,
                ),
                MyButton(
                  textString: "Sign Up",
                  onTap: signUserUp,
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text("Or Continue with"),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                      onTap: () {},
                      imagepath: 'lib/images/logo_apple.png',
                      height: 72,
                    ),
                    SizedBox(
                      width: 25,
                    ),
                    SquareTile(
                      onTap: signInwithGoogle,
                      imagepath: 'lib/images/google_logo.png',
                      height: 72,
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have a account? ",
                        style: TextStyle(
                          color: Colors.grey[700],
                        )),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "Login now",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
