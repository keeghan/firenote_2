import 'package:firenote_2/app_auth_manager.dart';
import 'package:firenote_2/auth_page.dart';
import 'package:firenote_2/notes_manager.dart';
import 'package:firenote_2/ui/edit_note_screen.dart';
import 'package:firenote_2/ui/widgets/auth_button.dart';
import 'package:firenote_2/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/note.dart';
import 'widgets/note_grid.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  static const String _gridViewPrefKey = "isGridView";
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _getGridViewPref();
  }

  //Change gridView preference and persist it
  void _toggleView() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_gridViewPrefKey, !_isGridView);
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: const SearchBar(),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_agenda : Icons.grid_view,
              color: Colors.white,
            ),
            onPressed: _toggleView,
            tooltip: _isGridView ? 'Switch to list view' : 'Switch to grid view',
          ),
          //Show User Icon
          Consumer<AppAuthManager>(builder: (context, authManager, _) {
            if (authManager.loggedIn) {
              return InkWell(
                // Tap to logout
                onTap: () => _showLogoutDialog(context, authManager),
                child: CircleAvatar(
                    backgroundColor: const Color(0xFF00B894),
                    child: Text(authManager.userChar, style: const TextStyle(color: Colors.white))),
              );
            } else {
              return SizedBox(
                width: 2,
              );
            }
          }),
          const SizedBox(width: 8),
        ],
      ),
      //User NotManager Consumer and StramBuilder to build notes
      body: Consumer<NoteManager>(
        builder: (context, noteManager, _) {
          if (!noteManager.isInitialized) {
            return _buildErrorBox(context, noteManager, "check Internet and Try again");
          }

          return StreamBuilder<List<Note>>(
            stream: noteManager.notesStream,
            builder: (context, snapshot) {
              //Handle error
              if (snapshot.hasError) {
                String errorMsg =
                    'Error: ${snapshot.error is StateError ? 'Please check your connection' : 'Unable to load notes'}';
                _buildErrorBox(context, noteManager, errorMsg);
              }

              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data != null && snapshot.data!.isEmpty) {
                return const Center(child: Text('Add notes'));
              }

              if (snapshot.data == null) {
                return _buildErrorBox(context, noteManager, "An unexpected Error Occured");
              }

              return NotesGrid(
                isGridView: _isGridView,
                notesList: snapshot.data ?? [],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: () {
          //Create new Note
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => EditNoteScreen(note: null)),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  //Get gridview preference
  Future<void> _getGridViewPref() async {
    final prefs = await SharedPreferences.getInstance();
    _isGridView = prefs.getBool(_gridViewPrefKey) ?? true;
    setState(() {});
  }
}

void _showLogoutDialog(BuildContext context, AppAuthManager authManager) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Logout Confirmation'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await authManager.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => AuthPage()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );
}

Widget _buildErrorBox(context, NoteManager noteManager, String errorMsg) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          errorMsg,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 16),
        AuthButton(
          text: 'Retry',
          onButtonPress: () async {
            try {
              await noteManager.refreshNotes();
            } catch (e) {
              if (context.mounted) {
                Utils.showSnackBar(context, 'Error: ${e.toString()}');
              }
            }
          },
          isStretched: false,
        ),
      ],
    ),
  );
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search your notes',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
