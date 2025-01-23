import 'package:firenote_2/state/authentication_bloc.dart';
import 'package:firenote_2/state/authentication_event.dart';
import 'package:firenote_2/state/authentication_state.dart';
import 'package:firenote_2/ui/widgets/auth_textfield.dart';
import 'package:firenote_2/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/auth_button.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _emailController = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        builder: (context, authState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //display circular loading icon
                  if (authState is AuthenticationLoadingState) ...[
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
                    onButtonPress: () {
                      validateEmail(_emailController.text);
                      if (_emailError != null) return;
                      FocusScope.of(context).unfocus();
                      context
                          .read<AuthenticationBloc>()
                          .add(RecoverUserPassword(_emailController.text));
                    },
                    isStretched: true,
                  ),
                ],
              ),
            ),
          );
        },
        listener: (BuildContext context, state) {
          if (state is AuthenticationActionSuccessState) {
            Utils.showPersistentToast(state.successMessage);
          }
          if (state is AuthenticationFailureState) {
            Utils.showPersistentToast(state.errorMessage);
          }
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
}
