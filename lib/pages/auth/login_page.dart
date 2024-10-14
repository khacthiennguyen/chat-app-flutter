
import 'package:chatapp/components/my_button.dart';
import 'package:chatapp/components/my_textfield.dart';
import 'package:chatapp/components/square_tile.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {
  final Function()? onTap;
  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text edit controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();



// sign in wwith email va password
  void signUserIn() async {
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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Đóng dialog khi signin ok
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Đóng loading dialog trước khi mở thông báo
      messengerPopup(e.code);
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                  "Welcome back",
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                const SizedBox(
                  height: 25,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                MyButton(
                  textString: "Sign In",
                  onTap: signUserIn,
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
                      onTap: () => _authService.signInwithGoogle(),
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
                    Text("Not a member? ",
                        style: TextStyle(
                          color: Colors.grey[700],
                        )),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "Register now",
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
