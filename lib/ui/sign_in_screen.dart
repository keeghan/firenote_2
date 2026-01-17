import 'package:firenote_2/state/authentication_bloc.dart';
import 'package:firenote_2/state/authentication_event.dart';
import 'package:firenote_2/state/authentication_state.dart';
import 'package:firenote_2/ui/widgets/auth_passwordfield.dart';
import 'package:firenote_2/ui/widgets/auth_textbutton.dart';
import 'package:firenote_2/ui/widgets/auth_textfield.dart';
import 'package:firenote_2/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final primary = Theme.of(context).colorScheme.primary;

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
                        // Spacer to match back button height in other screens
                        SizedBox(height: size.height * 0.1),

                        // Title
                        Text(
                          'Sign In\nto Continue',
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
                          'Please enter your credentials to access your secure notes.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: size.width * 0.04,
                            height: 1.5,
                          ),
                        ),

                        // Email
                        SizedBox(height: size.height * 0.05),
                        AuthTextField(
                          textEditingController: _emailController,
                          hintText: "Email",
                          onChanged: (value) => validateEmail(value),
                          errorText: _emailError,
                        ),

                        // Password
                        SizedBox(height: size.height * 0.01),
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
                        SizedBox(height: size.height * 0.02),
                        AuthButton(
                          text: 'SIGN IN',
                          onButtonPress: () {
                            validateEmail(_emailController.text);
                            validatePassword(_passwordController.text);
                            if (_emailError == null && _passwordError == null) {
                              FocusScope.of(context).unfocus();
                              context.read<AuthenticationBloc>().add(
                                    SignInUser(_emailController.text, _passwordController.text),
                                  );
                            }
                          },
                          isStretched: true,
                        ),

                        // SignUp Button
                        SizedBox(height: size.height * 0.03),
                        authTextButton(
                          color: primary,
                          size: size,
                          onButtonPress: () {
                            //reset error state
                            _emailError = null;
                            _passwordError = null;
                            context.go('/auth/signup');
                          },
                          text: "Don't have an Account? Create one",
                        ),

                        // Password Recovery Button
                        authTextButton(
                          color: primary,
                          size: size,
                          onButtonPress: () {
                            context.go('/auth/recover');
                          },
                          text: "Forgot Password?",
                        ),
                      ],
                    ),
                  ),
                ),

                // Cover screen with circularLoading icon
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
          //login redirected using go_router
          if (state is AuthenticationFailureState) {
            Utils.showShortToast(state.errorMessage);
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
