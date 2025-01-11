import 'package:firenote_2/ui/notes_screen.dart';
import 'package:firenote_2/ui/password_recovery_screen.dart';
import 'package:firenote_2/ui/sign_up_screen.dart';
import 'package:firenote_2/ui/widgets/auth_passwordfield.dart';
import 'package:firenote_2/ui/widgets/auth_textbutton.dart';
import 'package:firenote_2/ui/widgets/auth_textfield.dart';
import 'package:firenote_2/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_auth_manager.dart';
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
  late AppAuthManager _appAuthManager;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _appAuthManager = Provider.of<AppAuthManager>(context);

    return Scaffold(
      body: Consumer<AppAuthManager>(
        builder: (context, authState, _) {
          return Stack(
            children: [
              SafeArea(
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
                        isStretched: true,
                      ),

                      // SignUp Button
                      const SizedBox(height: 24),
                      AuthTextButton(
                        onButtonPress: () {
                          //reset error state
                          _emailError = null;
                          _passwordError = null;
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PasswordRecoveryScreen()),
                          );
                        },
                        text: "Forgot Password?",
                      ),
                    ],
                  ),
                ),
              ),
              //Cover screen with circularLoading icon
              if (authState.isLoading)
                Positioned(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
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

  void _handleSignIn() async {
    validateEmail(_emailController.text);
    validatePassword(_passwordController.text);
    if (_emailError == null && _passwordError == null) {
      FocusScope.of(context).unfocus();

      // String hashedPassword = Utils.encryptPassword(_passwordController.text);
      String? result = await _appAuthManager.signInWithEmailPassword(
          _emailController.text, _passwordController.text);
      if (!mounted) return;
      if (result == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => NotesScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        Utils.showSnackBar(context, result);
      }
    }
  }
}
