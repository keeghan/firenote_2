import 'package:firenote_2/app_auth_manager.dart';
import 'package:firenote_2/auth_page.dart';
import 'package:firenote_2/notes_manager.dart';
import 'package:firenote_2/ui/edit_note_screen.dart';
import 'package:firenote_2/ui/widgets/auth_button.dart';
import 'package:firenote_2/ui/widgets/note_screen_appbar.dart';
import 'package:firenote_2/utils/preference_service.dart';
import 'package:firenote_2/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/note.dart';
import 'widgets/note_grid.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _isGridView = true; //track note orientation
  bool _isSelection = false;
  final Set<String> _selectedNotes = {};

  @override
  void initState() {
    super.initState();
    PreferencesService.getIsGridView().then(
      (onValue) => _isGridView = onValue,
    );
  }

  //Change gridView preference and persist it
  void _toggleGridView() async {
    PreferencesService.setIsGridView(!_isGridView);
    setState(() => _isGridView = !_isGridView);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //   backgroundColor: const Color(0xFF121212),
      appBar:
          //  AppBar(
          //   backgroundColor: const Color(0xFF1E1E1E),
          //   leading: IconButton(
          //     icon: const Icon(Icons.menu, color: Colors.white),
          //     onPressed: () {},
          //   ),
          //   title: const SearchBar(),
          //   actions: [
          //     IconButton(
          //       icon: Icon(
          //         _isGridView ? Icons.view_agenda : Icons.grid_view,
          //         color: Colors.white,
          //       ),
          //       onPressed: _toggleView,
          //       tooltip: _isGridView ? 'Switch to list view' : 'Switch to grid view',
          //     ),
          //     //Show User Icon
          //     Consumer<AppAuthManager>(builder: (context, authManager, _) {
          //       if (authManager.loggedIn) {
          //         return InkWell(
          //           // Tap to logout
          //           onTap: () => _showLogoutDialog(context, authManager),
          //           child: CircleAvatar(
          //               backgroundColor: const Color(0xFF00B894),
          //               child: Text(authManager.userChar, style: const TextStyle(color: Colors.white))),
          //         );
          //       } else {
          //         return SizedBox(
          //           width: 2,
          //         );
          //       }
          //     }),
          //     const SizedBox(width: 8),
          //   ],
          // ),

          //Change appbar depending on whether a note is selected or note
          !_isSelection
              ? buildDefaultNoteBar(
                  _isGridView,
                  () => _toggleGridView(),
                  () => _showLogoutDialog(context),
                )
              : buildSelectionBar(
                  context,
                  () => onColorTap(),
                  () => onDeleteTap(),
                  () => onPinTap(),
                  () => onDuplicateTap(),
                  () => cleanUpAfterAction(),
                  _selectedNotes.length,
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

              if (snapshot.data == null) {
                return _buildErrorBox(context, noteManager, "An unexpected Error Occured");
              }

              if (snapshot.data != null && snapshot.data!.isEmpty) {
                return const Center(child: Text('Add notes'));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  noteManager.refreshNotes();
                },
                child: NotesGrid(
                  isGridView: _isGridView,
                  notesList: snapshot.data ?? [],
                  onTap: (note) {
                    if (!_isSelection) {
                      if (_selectedNotes.isNotEmpty) {
                        throw "Selection Error: left over notes"; //checks
                      }
                      //if no selection is going on navigate
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => EditNoteScreen(note: note)),
                      );
                    } else {
                      //in selection mode
                      setState(() {
                        if (_selectedNotes.contains(note.id)) {
                          //unSelect
                          _selectedNotes.remove(note.id);
                          if (_selectedNotes.isEmpty) {
                            _isSelection = false;
                          }
                        } else {
                          _selectedNotes.add(note.id);
                          if (_selectedNotes.length == 1) {
                            throw "Selection Error: less than 2"; //dhecks
                          }
                        }
                      });
                    }
                  },
                  onLongPress: (note) {
                    if (_isSelection) return;
                    //first selected
                    setState(() {
                      _isSelection = true;
                      _selectedNotes.add(note.id);
                      if (_selectedNotes.length > 1) throw "Selection Error: not first selection";
                    });
                  },
                  selectedNotes: _selectedNotes,
                ),
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

  //implement selection bar functions functions
  void onColorTap() {
    cleanUpAfterAction();
  }

  void onDeleteTap() {
    cleanUpAfterAction();
  }

  void onPinTap() {
    cleanUpAfterAction();
  }

  void onDuplicateTap() {
    cleanUpAfterAction();
  }

  void cleanUpAfterAction() {
    //TODO: remove toast
    showPersistentToast("action performed");
    setState(() {
      _selectedNotes.clear();
      _isSelection = false;
    });
  }
}

void _showLogoutDialog(BuildContext context) {
  AppAuthManager authMananger = context.read<AppAuthManager>();
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
              await authMananger.signOut();
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
