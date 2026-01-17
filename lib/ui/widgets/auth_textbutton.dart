import 'package:flutter/material.dart';

Widget authTextButton(
    {required String text,
    required Size size,
    required Color color,
    required VoidCallback onButtonPress}) {
  return TextButton(
    onPressed: onButtonPress,
    child: Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: size.height * 0.018,
      ),
    ),
  );
}
