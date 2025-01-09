import 'package:firenote_2/app_auth_manager.dart';
import 'package:firenote_2/ui/notes_screen.dart';
import 'package:firenote_2/ui/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuthManager>(builder: (context, authState, child) {
      print('loggedIn State: ${authState.loggedIn}');
      if (authState.loggedIn) {
        return NotesScreen();
      } else {
        return SignInScreen();
      }
    });
  }
}
