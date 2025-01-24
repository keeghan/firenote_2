import 'package:firenote_2/state/notes_bloc.dart';
import 'package:firenote_2/state/notes_event.dart';
import 'package:firenote_2/state/notes_state.dart';
import 'package:firenote_2/ui/widgets/note_color_picker.dart';
import 'package:firenote_2/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../data/note.dart';

class EditNoteScreen extends StatefulWidget {
  final Note? note;

  const EditNoteScreen({required this.note, super.key});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  Note currentNote = Note();
  bool _isEdit = false;
  bool _pinStatus = false;
  Color _noteColor = hexToColor('#00FFFFFF');
  DateTime _noteDateTime = DateTime.now();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  Note? _initialNote;

  @override
  void initState() {
    super.initState();
    //reset state
    context.read<NotesBloc>().add(ResetNotesActionState());
    //initialize new note or populate passed Note
    _isEdit = widget.note != null;
    if (_isEdit) {
      _initialNote = widget.note!.copy();
      currentNote = widget.note!.copy();
      _populateScreen(currentNote);
    } else {
      currentNote = Note();
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
    return BlocListener<NotesBloc, NotesState>(
      listener: (context, state) {
        //If _handleNoteExit is successful, display message and close
        //if it fails give user an option to stay or close anyway
        if (state.noteActionStatus == NoteActionStatus.success) {
          Utils.showShortToast(_isEdit ? 'note updated' : 'note saved');
          context.pop();
        } else if (state.noteActionStatus == NoteActionStatus.failure) {
          _showFailedSaveDialog(context, state.exception);
        }
      },
      //back press trigger _handleNoteExit
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          await _handleNoteExit(context);
        },
        child: Scaffold(
          backgroundColor: _noteColor,
          appBar: AppBar(
            backgroundColor: _noteColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () async => await _handleNoteExit(context),
            ),
            actions: [
              IconButton(
                onPressed: () => setState(() => _pinStatus = !_pinStatus),
                icon: Icon(_pinStatus ? Icons.push_pin : Icons.push_pin_outlined,
                    color: Colors.white),
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
              Container(
                decoration: BoxDecoration(
                  color: _noteColor,
                  border: Border(top: BorderSide(color: Colors.white)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.palette_outlined, color: Colors.white),
                      onPressed: () => _showColorPicker(context),
                    ),
                    Text(
                      'Edited ${formatLastEdited(_noteDateTime)}',
                      style: TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {
                        Utils.showShortToast('feature not implemented');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleNoteExit(BuildContext context) async {
    // Update note data from controllers
    currentNote.title = _titleController.text;
    currentNote.message = _contentController.text;
    currentNote.color = colorToHex(_noteColor);
    currentNote.pinStatus = _pinStatus;

    // Skip if message is empty
    if (currentNote.message.isEmpty) {
      context.pop();
      return;
    }

    // Skip if no changes were made
    if (_isEdit && !_isNoteChanged()) {
      context.pop();
      return;
    }

    // Save or update note
    if (_isEdit) {
      context.read<NotesBloc>().add(UpdateNote(currentNote));
    } else {
      context.read<NotesBloc>().add(SaveNote(currentNote));
    }
  }

  void _populateScreen(Note note) {
    _noteDateTime = parseFormattedDateTime(note.dateTimeString);
    _noteColor = hexToColor(note.color);
    _titleController.text = note.title;
    _contentController.text = note.message;
    _pinStatus = note.pinStatus;
    setState(() {});
  }

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

  bool _isNoteChanged() {
    return _initialNote!.title != _titleController.text ||
        _initialNote!.message != _contentController.text ||
        _initialNote!.color != colorToHex(_noteColor) ||
        _initialNote!.pinStatus != _pinStatus;
  }

  Future<void> _showFailedSaveDialog(BuildContext context, Exception? exception) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(_isEdit ? 'update failed' : 'save sailed'),
          content: Text(exception?.toString() ?? 'unknown error occurred'),
          actions: [
            TextButton(
              child: const Text('ok'),
              onPressed: () => context.pop(),
            ),
          ],
        );
      },
    );
  }
}
