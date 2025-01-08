import 'package:flutter/material.dart';

class AuthTextButton extends StatelessWidget {
  final VoidCallback onButtonPress;
  final String text;

  const AuthTextButton({super.key, required this.onButtonPress, required this.text});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onButtonPress,
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 16,
        ),
      ),
    );
  }
}
