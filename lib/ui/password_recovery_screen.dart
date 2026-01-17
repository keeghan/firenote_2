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
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        builder: (context, authState) {
          return SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(size.width * 0.06),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.03),

                        // Back button
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          iconSize: size.width * 0.07,
                        ),

                        SizedBox(height: size.height * 0.03),

                        // Title
                        Text(
                          'Recover Your\nPassword',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.08,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),

                        SizedBox(height: size.height * 0.015),

                        // Subtitle
                        Text(
                          'Enter your email address and we\'ll send you a link to reset your password.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: size.width * 0.04,
                            height: 1.5,
                          ),
                        ),

                        // Email field
                        SizedBox(height: size.height * 0.05),
                        AuthTextField(
                          textEditingController: _emailController,
                          hintText: "Email",
                          onChanged: (value) => validateEmail(value),
                          errorText: _emailError,
                        ),

                        // Send button
                        SizedBox(height: size.height * 0.03),
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

                        // Spam notice
                        SizedBox(height: size.height * 0.03),
                        Container(
                          padding: EdgeInsets.all(size.width * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange.shade300,
                                size: size.width * 0.05,
                              ),
                              SizedBox(width: size.width * 0.03),
                              Expanded(
                                child: Text(
                                  'Check your spam folder if you don\'t see the recovery email in your inbox within a few minutes.',
                                  style: TextStyle(
                                    color: Colors.orange.shade100,
                                    fontSize: size.width * 0.035,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: size.height * 0.05),
                      ],
                    ),
                  ),
                ),

                // Loading overlay
                if (authState is AuthenticationLoadingState)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
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
