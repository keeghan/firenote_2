import 'package:firenote_2/ui/sign_up_screen.dart';
import 'package:firenote_2/ui/widgets/auth_passwordfield.dart';
import 'package:firenote_2/ui/widgets/auth_textbutton.dart';
import 'package:firenote_2/ui/widgets/auth_textfield.dart';
import 'package:firenote_2/utils/utils.dart';
import 'package:flutter/material.dart';

import 'widgets/auth_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _obscureText = true;
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  void _handleSignIn() {
    validateEmail(_emailController.text);
    validatePassword(_passwordController.text);
    if (_emailError == null && _passwordError == null) {
      // TODO: Implement sign in logic
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sign into account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
          
              // Email
              const SizedBox(height: 32),
              AuthTextField(
                textEditingController: _emailController,
                hintText: "Email",
                onChanged: (value) => validateEmail(value),
                errorText: _emailError,
              ),
          
              // Password
              const SizedBox(height: 16),
              AuthPasswordField(
                textEditingController: _passwordController,
                hintText: 'Enter password',
                obscureText: _obscureText,
                onChanged: (value) => validatePassword(value),
                errorText: _passwordError,
                onVissibilityToggle: () {
                  setState(() => _obscureText = !_obscureText);
                },
              ),
          
              // SignIn Button
              const SizedBox(height: 24),
              AuthButton(
                text: 'SIGN IN',
                onButtonPress: _handleSignIn,
              ),
          
              // SignUp Button
              const SizedBox(height: 24),
              AuthTextButton(
                onButtonPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                },
                text: "Don't have an Account?",
              ),
          
              // Password Recovery Button
              AuthTextButton(
                onButtonPress: () {
                  // TODO: password recovery
                },
                text: "Forgot Password",
              ),
            ],
          ),
        ),
      ),
    );
  }

  //validation Methods
  void validateEmail(String? value) {
    setState(() {
      if (value == null || value.isEmpty) {
        _emailError = 'Email is required';
      } else if (!ValidationUtils.isValidEmail(value)) {
        _emailError = 'Please enter a valid email';
      } else {
        _emailError = null;
      }
    });
  }

  void validatePassword(String? value) {
    setState(() {
      if (value == null || value.isEmpty) {
        _passwordError = 'Password is required';
      } else if (value.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }
    });
  }
}
