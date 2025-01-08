import 'package:firenote_2/ui/widgets/auth_button.dart';
import 'package:firenote_2/ui/widgets/auth_passwordfield.dart';
import 'package:firenote_2/ui/widgets/auth_textbutton.dart';
import 'package:firenote_2/ui/widgets/auth_textfield.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscureText = true;
  bool _obscureConfirmationText = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Create An Account',
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

              //Password Confirmation
              const SizedBox(height: 16),
              AuthPasswordField(
                textEditingController: _confirmationController,
                hintText: 'Confirm password',
                obscureText: _obscureConfirmationText,
                onVissibilityToggle: () {
                  setState(() => _obscureConfirmationText = !_obscureConfirmationText);
                },
              ),

              const SizedBox(height: 24),
              AuthButton(
                text: 'SIGN UP',
                onButtonPress: () {
                  //TODO: singup implementation
                },
              ),

              //SignUp Button
              const SizedBox(height: 24),
              AuthTextButton(
                onButtonPress: () {
                  Navigator.pop(context);
                },
                text: "Already Have an Account?",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
