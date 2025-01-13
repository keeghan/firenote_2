import 'package:firenote_2/notes_manager.dart';
import 'package:firenote_2/ui/widgets/note_color_picker.dart';
import 'package:firenote_2/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/note.dart';

class EditNoteScreen extends StatefulWidget {
  final Note? note;

  const EditNoteScreen({required this.note, super.key});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  Note note = Note();
  bool _isEdit = false;
  bool _pinStatus = false;
  Color _noteColor = Colors.black;
  DateTime _noteDateTime = DateTime.now();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  Note? _initialNote;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.note != null;
    if (_isEdit) {
      //store initial note for save checks and copy note to
      //populate screen and hold new values
      _initialNote = widget.note!.copy();
      note = widget.note!.copy();
      _populateScreen(note);
    } else {
      note = Note();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Save or Edit note when user goes back
    //ask confirmation if save or edit fail
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        if (context.mounted) {
          bool success = await _saveNote(context);
          if (success) {
            Navigator.pop(context);
          } else {
            bool userExit = await _showFailedSaveDialog(context);
            if (userExit) {
              Navigator.pop(context);
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: _noteColor,
        appBar: AppBar(
          backgroundColor: _noteColor,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () async {
                // handle save/edit or exit
                bool success = await _saveNote(context);
                if (success) {
                  Navigator.pop(context);
                } else {
                  bool userExit = await _showFailedSaveDialog(context);
                  if (userExit) {
                    Navigator.pop(context);
                  }
                }
              }),
          actions: [
            IconButton(
              onPressed: () => setState(() => _pinStatus = !_pinStatus),
              icon:
                  Icon(_pinStatus ? Icons.push_pin : Icons.push_pin_outlined, color: Colors.white),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Title TextField
                    TextField(
                      controller: _titleController,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                    ),
                    // Content TextField
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'What is happening!',
                          hintStyle: TextStyle(
                            color: Colors.white38,
                            fontStyle: FontStyle.italic,
                          ),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Bar
            Container(
              decoration: BoxDecoration(
                color: _noteColor,
                border: Border(
                  top: BorderSide(color: Colors.white),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.palette_outlined, color: Colors.white),
                    onPressed: () {
                      _showColorPicker(context);
                    },
                  ),
                  Text(
                    'Edited ${formatLastEdited(_noteDateTime)}',
                    style: TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {
                      //TODO: implement more features
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //If editing note populate screen
  void _populateScreen(Note note) {
    _noteDateTime = parseFormattedDateTime(note.dateTimeString);
    _noteColor = hexToColor(note.color);
    _titleController.text = note.title;
    _contentController.text = note.message;
    _pinStatus = note.pinStatus;
    setState(() {});
  }

  //show color picker and pick new Color
  void _showColorPicker(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: _noteColor,
      context: context,
      builder: (context) {
        return NoteColorPicker(
          initialColor: _noteColor,
          onColorChanged: (colorHex) {
            setState(() => _noteColor = hexToColor(colorHex));
          },
          isGridView: false,
        );
      },
    );
  }

  //save Note
  Future<bool> _saveNote(BuildContext context) async {
    // Update note data from controllers
    note.title = _titleController.text;
    note.message = _contentController.text;
    note.color = colorToHex(_noteColor);
    note.pinStatus = _pinStatus;
    //skip if messsaage is empty
    if (note.message.isEmpty) {
      return true;
    }
    //skip if not changes were made
    if (_isEdit && !_isNoteChanged()) {
      return true;
    }
    //save or update
    final noteManager = context.read<NoteManager>();
    String? error;
    String success = "";
    if (_isEdit) {
      error = await noteManager.updateNote(note);
      success = "note updated";
    } else {
      error = await noteManager.saveNote(note);
      success = "note saved";
    }
    error != null ? showPersistentToast('error: $error') : showPersistentToast(success);
    return error == null;
  }

  //Determine if note has changed since this screen was open
  bool _isNoteChanged() {
    return _initialNote!.title != _titleController.text ||
        _initialNote!.message != _contentController.text ||
        _initialNote!.color != colorToHex(_noteColor) ||
        _initialNote!.pinStatus != _pinStatus;
  }

  Future<bool> _showFailedSaveDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(''),
          content: SingleChildScrollView(
            child: Text(_isEdit ? "edit failed" : 'save failed'),
          ),
          actions: [
            TextButton(
              child: const Text('cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('exit anyway'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  // void _handleExit(BuildContext context) async {
  //   if (mounted) {
  //     bool success = await _saveNote(context);
  //     if (success) {
  //       Navigator.pop(context);
  //     } else {
  //       if (!mounted) {
  //         bool exit = await _showFailedSaveDialog(context);
  //         if (exit) Navigator.pop(context);
  //       }
  //     }
  //   }
  // }
}
