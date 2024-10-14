
import 'package:chatapp/pages/auth/login_page.dart';
import 'package:chatapp/pages/auth/resgister_page.dart';
import 'package:flutter/material.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {

  bool showLoginPage = true;

  //toggle betwweetn login and register page
  void togglePage(){
    setState(() {
      showLoginPage=! showLoginPage;

    });
  }
  @override
  Widget build(BuildContext context) {
    if (showLoginPage){
      return LoginPage(onTap: togglePage);
    }
    else{
      return ResgisterPage(onTap: togglePage);
    }
  }
}