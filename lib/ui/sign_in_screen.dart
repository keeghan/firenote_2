import 'package:firenote_2/ui/sign_up_screen.dart';
import 'package:firenote_2/ui/widgets/auth_passwordfield.dart';
import 'package:firenote_2/ui/widgets/auth_textbutton.dart';
import 'package:firenote_2/ui/widgets/auth_textfield.dart';
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
              //Email
              const SizedBox(height: 32),
              AuthTextField(textEditingController: _emailController, hintText: "Email"),

              //passowrd
              const SizedBox(height: 16),
              AuthPasswordField(
                textEditingController: _passwordController,
                hintText: 'Enter password',
                obscureText: _obscureText,
                onVissibilityToggle: () {
                  setState(() => _obscureText = !_obscureText);
                },
              ),

              //SignInButton
              const SizedBox(height: 24),
              AuthButton(
                text: 'SIGN IN',
                onButtonPress: () {
                  //TODO: signIn implementation
                },
              ),

              //SignUp Button
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

              //PasswordRecoveryButton
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
}
