
import 'package:flutter/material.dart';

class MyAlertDialog extends StatelessWidget {
  String text;
   MyAlertDialog({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(text),
    );
  }
}