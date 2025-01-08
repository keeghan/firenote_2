import 'package:flutter/material.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Center(
        child: Column(
          children: [
            Text("Welcome to notes"),
            ElevatedButton(
                onPressed: () async {
                  // await FirebaseAuth.instance.signOut();
                },
                child: Text("Sign Out"))
          ],
        ),
      ),
    );
  }
}
