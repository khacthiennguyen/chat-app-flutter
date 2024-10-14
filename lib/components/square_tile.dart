import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final void Function()? onTap;
  final String imagepath;
  final double height;
  const SquareTile({super.key,required this.onTap, required this.imagepath, required this.height});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        child: Image.asset(
          imagepath,
          height: height,
        ),
      ),
    );
  }
}
