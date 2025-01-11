import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onButtonPress;
  final bool isStretched; 

  const AuthButton({super.key, required this.text, required this.onButtonPress, required this.isStretched});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isStretched ? double.infinity : null,
      height: 50,
      child: ElevatedButton(
        onPressed: onButtonPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
