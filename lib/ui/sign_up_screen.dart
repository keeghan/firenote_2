import 'package:firenote_2/state/authentication_bloc.dart';
import 'package:firenote_2/state/authentication_event.dart';
import 'package:firenote_2/state/authentication_state.dart';
import 'package:firenote_2/ui/widgets/auth_button.dart';
import 'package:firenote_2/ui/widgets/auth_passwordfield.dart';
import 'package:firenote_2/ui/widgets/auth_textbutton.dart';
import 'package:firenote_2/ui/widgets/auth_textfield.dart';
import 'package:firenote_2/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

  String? _emailError;
  String? _passwordError;
  String? _confirmationError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        builder: (context, authState) {
          return Stack(
            children: [
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Create An Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        // Email
                        const SizedBox(height: 32),
                        AuthTextField(
                          textEditingController: _emailController,
                          hintText: "Email",
                          errorText: _emailError,
                          onChanged: validateEmail,
                        ),

                        // Password
                        const SizedBox(height: 16),
                        AuthPasswordField(
                          textEditingController: _passwordController,
                          hintText: 'Enter password',
                          obscureText: _obscureText,
                          errorText: _passwordError,
                          onChanged: validatePassword,
                          onVissibilityToggle: () {
                            setState(() => _obscureText = !_obscureText);
                          },
                        ),

                        // Password Confirmation
                        const SizedBox(height: 16),
                        AuthPasswordField(
                          textEditingController: _confirmationController,
                          hintText: 'Confirm password',
                          obscureText: _obscureConfirmationText,
                          errorText: _confirmationError,
                          onChanged: validateConfirmation,
                          onVissibilityToggle: () {
                            setState(() => _obscureConfirmationText = !_obscureConfirmationText);
                          },
                        ),

                        const SizedBox(height: 24),
                        AuthButton(
                          text: 'SIGN UP',
                          onButtonPress: () {
                            if (isFormValid()) {
                              FocusScope.of(context).unfocus();

                              context.read<AuthenticationBloc>().add(
                                    SignUpUser(
                                      _emailController.text,
                                      _passwordController.text,
                                    ),
                                  );
                            }
                          },
                          isStretched: true,
                        ),

                        // Sign In Button
                        const SizedBox(height: 24),
                        AuthTextButton(
                          onButtonPress: () => context.pop(),
                          text: "Already Have an Account?",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //Cover screen with circularLoading icon
              if (authState is AuthenticationLoadingState)
                Positioned(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
        listener: (BuildContext context, state) {
          //login redirected using go_router
          if (state is AuthenticationFailureState) {
            Utils.showShortToast(state.errorMessage);
          }
        },
      ),
    );
  }

  //Validation Methods
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

      if (_confirmationController.text.isNotEmpty) {
        validateConfirmation(_confirmationController.text);
      }
    });
  }

  void validateConfirmation(String? value) {
    setState(() {
      if (value == null || value.isEmpty) {
        _confirmationError = 'Please confirm your password';
      } else if (value != _passwordController.text) {
        _confirmationError = 'Passwords do not match';
      } else {
        _confirmationError = null;
      }
    });
  }

  bool isFormValid() {
    validateEmail(_emailController.text);
    validatePassword(_passwordController.text);
    validateConfirmation(_confirmationController.text);
    return _emailError == null && _passwordError == null && _confirmationError == null;
  }
}
