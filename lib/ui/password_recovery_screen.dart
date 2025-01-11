import 'package:firenote_2/ui/widgets/auth_textfield.dart';
import 'package:firenote_2/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_auth_manager.dart';
import 'widgets/auth_button.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _emailController = TextEditingController();
  String? _emailError;
  late AppAuthManager _appAuthManager;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _appAuthManager = Provider.of<AppAuthManager>(context);

    return Scaffold(
      body: Consumer<AppAuthManager>(
        builder: (context, authState, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //display circular loading icon
                  if (authState.isLoading) ...[
                    Positioned(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  const Text(
                    'Recover Your Password',
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

                  // SignIn Button
                  const SizedBox(height: 24),
                  AuthButton(
                    text: 'SEND RECOVERY EMAIL',
                    onButtonPress: _handleSendRecoveryEmail,
                    isStretched: true,
                  ),
                ],
              ),
            ),
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

  void _handleSendRecoveryEmail() async {
    validateEmail(_emailController.text);
    if (_emailError != null) return;
    FocusScope.of(context).unfocus();

    String? result = await _appAuthManager.recoverPassword(_emailController.text);
    if (!mounted) return;
    if (result == null) {
      Utils.showSnackBar(context, 'Recovery Email sent');
      Navigator.pop(context); //Go Back to signIn screen
    } else {
      Utils.showSnackBar(context, result);
    }
  }
}
