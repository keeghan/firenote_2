import 'package:firenote_2/state/authentication_bloc.dart';
import 'package:firenote_2/state/authentication_event.dart';
import 'package:firenote_2/state/notes_bloc.dart';
import 'package:firenote_2/state/notes_event.dart';
import 'package:firenote_2/state/notes_state.dart';
import 'package:firenote_2/ui/widgets/auth_button.dart';
import 'package:firenote_2/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../data/note.dart';
import 'widgets/note_color_picker.dart';
import 'widgets/note_grid.dart';
import 'widgets/note_screen_appbar.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state.noteStatus == NoteStatus.failure) {
          Utils.showShortToast(state.exception.toString());
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: !state.isMultiSelectionMode
              ? buildDefaultNoteBar(
                  state.isGridView,
                  () => context.read<NotesBloc>().add(ToggleGridView()),
                  () => _showLogoutDialog(context),
                )
              : buildSelectionBar(
                  context,
                  () => _showColorPickerDialog(context, state.selectedNotes),
                  () => context.read<NotesBloc>().add(DeleteNotes()),
                  () => context.read<NotesBloc>().add(ToggleNotesPin()),
                  () => context.read<NotesBloc>().add(DuplicateNotes()),
                  () => context.read<NotesBloc>().add(ClearSelection()),
                  state.selectedNotes.length,
                ),
          body: _buildBody(context, state),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            onPressed: () => context.go('/notes/edit'),
            child: const Icon(Icons.add, color: Colors.black),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, NotesState state) {
    switch (state.noteStatus) {
      case NoteStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case NoteStatus.failure:
        return _buildErrorBox(context, state.exception.toString());

      case NoteStatus.success:
        if (state.notes == null) {
          return _buildErrorBox(context, 'Failed to retrieve notes');
        }

        if (state.notes!.isEmpty) {
          return const Center(child: Text('No notes. Add a new note!'));
        }

        return NotesGrid(
          isGridView: state.isGridView,
          notesList: state.notes!,
          onTap: (note) {
            if (!state.isMultiSelectionMode) {
              context.go('/notes/edit', extra: note);
            } else {
              context.read<NotesBloc>().add(OnNoteTap(note));
            }
          },
          onLongPress: (note) {
            if (!state.isMultiSelectionMode) {
              context.read<NotesBloc>().add(OnLongPress(note));
            }
          },
          selectedNotes: state.selectedNotes.map((note) => note.id).toSet(),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildErrorBox(BuildContext context, String errorMsg) {
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
            onButtonPress: () {
              context.read<NotesBloc>().add(LoadNotes());
            },
            isStretched: false,
          ),
        ],
      ),
    );
  }

  Future<void> _showColorPickerDialog(BuildContext context, Set<Note> selectedNotes) async {
    final color = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NoteColorPicker(
              initialColor: Colors.transparent,
              onColorChanged: (colorHex) {
                Navigator.of(context).pop(colorHex);
              },
              isGridView: true,
            ),
          ],
        ),
      ),
    );

    if (color != null && context.mounted) {
      context.read<NotesBloc>().add(ChangeNotesColor(color));
    }
  }

  void _showLogoutDialog(BuildContext context) {
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
              onPressed: () {
                Navigator.pop(context);
                //go_router redirects
                context.read<AuthenticationBloc>().add(SignOutUser());
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
