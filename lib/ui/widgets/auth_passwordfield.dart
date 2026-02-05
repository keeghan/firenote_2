import 'package:flutter/material.dart';

class AuthPasswordField extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final bool obscureText;
  final VoidCallback onVissibilityToggle;
  final String? errorText;
  final void Function(String)? onChanged;

  const AuthPasswordField({
    super.key,
    required this.textEditingController,
    required this.hintText,
    required this.obscureText,
    required this.onVissibilityToggle,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return TextField(
      controller: textEditingController,
      obscureText: obscureText,
      style: TextStyle(color: onSurface),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        helperText: errorText == null ? ' ' : null,
        errorStyle: const TextStyle(color: Colors.redAccent),
        helperStyle: const TextStyle(color: Colors.transparent),
        hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.5)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.redAccent, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: onSurface.withValues(alpha: 0.5),
          ),
          onPressed: onVissibilityToggle,
        ),
      ),
    );
  }
}
