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
      currentNote.color = "#00FFFFFF";
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
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          await _handleNoteExit(context);
        },
        child: Builder(
          builder: (context) {
            final isTransparent = currentNote.color == NoteColors.transparent;
            final bgColor = isTransparent
                ? Theme.of(context).colorScheme.surface
                : hexToColor(currentNote.color);
            final textColor = noteTextColor(currentNote.color, Theme.of(context).brightness);
            final hintColor = noteHintColor(currentNote.color, Theme.of(context).brightness);
            return Scaffold(
              backgroundColor: bgColor,
              appBar: AppBar(
                backgroundColor: bgColor,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: textColor),
                  onPressed: () async => await _handleNoteExit(context),
                ),
                actions: [
                  IconButton(
                    onPressed: () => setState(() => _pinStatus = !_pinStatus),
                    icon: Icon(_pinStatus ? Icons.push_pin : Icons.push_pin_outlined,
                        color: textColor),
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
                              color: textColor.withValues(alpha: 0.7),
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Title',
                              hintStyle: TextStyle(color: hintColor),
                              border: InputBorder.none,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _contentController,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText: 'What is happening!',
                                hintStyle: TextStyle(
                                  color: hintColor,
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
                      color: bgColor,
                      border: Border(top: BorderSide(color: textColor.withValues(alpha: 0.3))),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.palette_outlined, color: textColor),
                          onPressed: () => _showColorPicker(context),
                        ),
                        Text(
                          'Edited ${formatLastEdited(_noteDateTime)}',
                          style: TextStyle(color: textColor),
                        ),
                        IconButton(
                          icon: Icon(Icons.more_vert, color: textColor),
                          onPressed: () {
                            Utils.showShortToast('feature not implemented');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleNoteExit(BuildContext context) async {
    // Update note data from controllers
    currentNote.title = _titleController.text;
    currentNote.message = _contentController.text;
    //use original noteColor String or one set in _showColorPicker
    currentNote.pinStatus = _pinStatus;

    // Skip if both title and message are empty
    if (currentNote.title.trim().isEmpty && currentNote.message.trim().isEmpty) {
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
    _titleController.text = note.title;
    _contentController.text = note.message;
    _pinStatus = note.pinStatus;
    setState(() {});
  }

  void _showColorPicker(BuildContext context) {
    final isTransparent = currentNote.color == NoteColors.transparent;
    final sheetBg = isTransparent
        ? Theme.of(context).colorScheme.surface
        : hexToColor(currentNote.color);
    showModalBottomSheet(
      backgroundColor: sheetBg,
      context: context,
      builder: (context) {
        return NoteColorPicker(
          initialColor: hexToColor(currentNote.color),
          onColorChanged: (colorHex) {
            setState(() => currentNote.color = colorHex);
          },
          isGridView: false,
        );
      },
    );
  }

  bool _isNoteChanged() {
    return _initialNote!.title != _titleController.text ||
        _initialNote!.message != _contentController.text ||
        _initialNote!.color != currentNote.color ||
        _initialNote!.pinStatus != _pinStatus;
  }

  Future<void> _showFailedSaveDialog(BuildContext context, Exception? exception) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(_isEdit ? 'update failed' : 'save failed'),
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
