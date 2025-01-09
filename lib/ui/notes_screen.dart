import 'package:firenote_2/app_auth_manager.dart';
import 'package:firenote_2/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/utils.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late AppAuthManager _appAuthManager;

  @override
  Widget build(BuildContext context) {
    _appAuthManager = Provider.of<AppAuthManager>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Center(
        child: Column(
          children: [
            Text("Welcome to notes"),
            ElevatedButton(
              onPressed: () async {
                if (!mounted) return;
                Utils.showSnackBar(context, 'logging out');
                await _appAuthManager.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => AuthPage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text("Sign Out"),
            )
          ],
        ),
      ),
    );
  }
}
