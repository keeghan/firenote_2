// import 'package:firenote_2/app_auth_manager.dart';
// import 'package:firenote_2/notes_manager.dart';
// import 'package:firenote_2/ui/edit_note_screen.dart';
// import 'package:firenote_2/ui/widgets/auth_button.dart';
// import 'package:firenote_2/ui/widgets/note_screen_appbar.dart';
// import 'package:firenote_2/utils/preference_service.dart';
// import 'package:firenote_2/utils/utils.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import '../data/note.dart';
// import 'widgets/note_color_picker.dart';
// import 'widgets/note_grid.dart';

// class NotesScreen extends StatefulWidget {
//   const NotesScreen({super.key});

//   @override
//   State<NotesScreen> createState() => _NotesScreenState();
// }

// class _NotesScreenState extends State<NotesScreen> {
//   bool _isGridView = true; //track note orientation
//   bool _isSelection = false;
//   final Set<Note> _selectedNotes = {};

//   @override
//   void initState() {
//     super.initState();
//     PreferencesService.getIsGridView().then(
//       (onValue) => _isGridView = onValue,
//     );
//   }

//   //Change gridView preference and persist it
//   void _toggleGridView() async {
//     PreferencesService.setIsGridView(!_isGridView);
//     setState(() => _isGridView = !_isGridView);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       //Change appbar depending on whether a note is selected or note
//       appBar: !_isSelection
//           ? buildDefaultNoteBar(
//               _isGridView,
//               () => _toggleGridView(),
//               () => _showLogoutDialog(context),
//             )
//           : buildSelectionBar(
//               context,
//               () => onColorTap(),
//               () => onDeleteTap(),
//               () => onPinTap(),
//               () => onDuplicateTap(),
//               () => afterActionDone("cancelled"),
//               _selectedNotes.length,
//             ),
//       //User NoteManager Consumer and StramBuilder to build notes
//       body: Consumer<NoteManager>(
//         builder: (context, noteManager, _) {
//           //If not initiallized present errorbox,
//           //to prevent null exception on database ref
//           if (!noteManager.isInitialized && !noteManager.isLoading) {
//             return _buildErrorBox(context, noteManager, "check Internet and Try again");
//           }

//           return StreamBuilder<List<Note>>(
//             stream: noteManager.notesStream,
//             builder: (context, snapshot) {
//               //Handle error
//               if (snapshot.hasError) {
//                 String errorMsg =
//                     'Error: ${snapshot.error is StateError ? 'Please check your connection' : 'Unable to load notes'}';
//                 _buildErrorBox(context, noteManager, errorMsg);
//               }
//               //if loading list display progress indicator
//               if (noteManager.isLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (snapshot.data == null) {
//                 return _buildErrorBox(context, noteManager, "check your internet and Try again");
//               }

//               if (snapshot.data != null && snapshot.data!.isEmpty) {
//                 return const Center(child: Text('Add notes'));
//               }

//               return RefreshIndicator(
//                 onRefresh: () async {
//                   noteManager.refreshNotes();
//                 },
//                 child: NotesGrid(
//                   isGridView: _isGridView,
//                   notesList: snapshot.data ?? [],
//                   onTap: (note) {
//                     if (!_isSelection) {
//                       if (_selectedNotes.isNotEmpty) {
//                         throw "Selection Error: left over notes"; //checks
//                       }
//                       //if no selection is going on navigate
//                       Navigator.of(context).push(
//                         MaterialPageRoute(builder: (context) => EditNoteScreen(note: note)),
//                       );
//                     } else {
//                       //in selection mode
//                       setState(() {
//                         if (_selectedNotes.contains(note)) {
//                           //TODO: note comparisons
//                           //unSelect
//                           _selectedNotes.remove(note);
//                           if (_selectedNotes.isEmpty) {
//                             _isSelection = false;
//                           }
//                         } else {
//                           _selectedNotes.add(note);
//                           if (_selectedNotes.length == 1) {
//                             throw "Selection Error: less than 2"; //dhecks
//                           }
//                         }
//                       });
//                     }
//                   },
//                   onLongPress: (note) {
//                     if (_isSelection) return;
//                     //first selected
//                     setState(() {
//                       _isSelection = true;
//                       _selectedNotes.add(note);
//                       if (_selectedNotes.length > 1) throw "Selection Error: not first selection";
//                     });
//                   },
//                   //Set of Objects not working for noteObject highlight
//                   selectedNotes: _selectedNotes.map((note) => note.id).toSet(),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//         onPressed: () {
//           //Create new Note
//           Navigator.of(context).push(
//             MaterialPageRoute(builder: (context) => EditNoteScreen(note: null)),
//           );
//         },
//         child: const Icon(Icons.add, color: Colors.black),
//       ),
//     );
//   }

// //=======================================================================

//   // implement selection bar functions functions
//   Future<void> onColorTap() async {
//     String? color = await _showColorPickerDialog(context);
//     if (color != null) {
//       String? error = await Provider.of<NoteManager>(context, listen: false)
//           .changeNotesColor(_selectedNotes, color);
//       afterActionDone(error);
//     }
//   }

//   void onDeleteTap() async {
//     String? error = await Provider.of<NoteManager>(context, listen: false).deleteNotes(
//       _selectedNotes,
//     );
//     afterActionDone(error);
//   }

//   Future<void> onPinTap() async {
//     String? error = await Provider.of<NoteManager>(context, listen: false).togglePinStatuses(
//       _selectedNotes,
//     );
//     afterActionDone(error);
//   }

//   void onDuplicateTap() async {
//     String? error = await Provider.of<NoteManager>(context, listen: false).duplicateNotes(
//       _selectedNotes,
//     );
//     afterActionDone(error);
//   }

//   void afterActionDone(String? error) {
//     setState(() {
//       _selectedNotes.clear();
//       _isSelection = false;
//     });
//     (error == null) ? showPersistentToast("success") : showPersistentToast(error);
//   }
// }

// //=================Widgets======================
// void _showLogoutDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('Logout Confirmation'),
//         content: const Text('Are you sure you want to log out?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               AppAuthManager authMananger = context.read<AppAuthManager>();
//               await authMananger.signOut();
//               // Navigator.of(context).pushAndRemoveUntil(
//               //   MaterialPageRoute(builder: (context) => AuthPage()),
//               //   (Route<dynamic> route) => false,
//               // );
//               if(!context.mounted) return;
//               context.go('/auth/login'); // Go to login
//             },
//             child: const Text('Logout'),
//           ),
//         ],
//       );
//     },
//   );
// }

// Future<dynamic> _showColorPickerDialog(BuildContext context) async {
//   return showDialog(
//     context: context,
//     barrierDismissible: true, // Allow dismissal by tapping outside
//     builder: (context) {
//       return Dialog(
//         // Use Dialog instead of AlertDialog
//         backgroundColor: Colors.transparent, // Make background transparent
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             NoteColorPicker(
//               initialColor: Colors.transparent,
//               onColorChanged: (colorHex) {
//                 Navigator.of(context).pop(colorHex);
//               },
//               isGridView: true,
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

// Widget _buildErrorBox(context, NoteManager noteManager, String errorMsg) {
//   return Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           errorMsg,
//           style: const TextStyle(color: Colors.white70),
//         ),
//         const SizedBox(height: 16),
//         AuthButton(
//           text: 'Retry',
//           onButtonPress: () async {
//             try {
//               await noteManager.refreshNotes();
//             } catch (e) {
//               if (context.mounted) {
//                 Utils.showSnackBar(context, 'Error: ${e.toString()}');
//               }
//             }
//           },
//           isStretched: false,
//         ),
//       ],
//     ),
//   );
// }
