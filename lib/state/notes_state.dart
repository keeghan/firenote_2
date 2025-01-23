import '../data/note.dart';

enum NoteStatus { initial, loading, success, failure }

final class NotesState {
  final bool isMultiSelectionMode;
  final bool isGridView;
  final NoteStatus noteStatus;
  final List<Note> notes;
  final Set<Note> selectedNotes;
  final Exception? exception;

  NotesState({
    this.isMultiSelectionMode = false,
    this.notes = const <Note>[],
    this.selectedNotes = const <Note>{},
    this.exception = null,
    this.isGridView = false,
    this.noteStatus = NoteStatus.initial,
  });

  NotesState copyWith({
    bool? isMultiSelectionMode,
    bool? isGridView,
    NoteStatus? noteStatus,
    List<Note>? notes,
    Set<Note>? selectedNotes,
    Exception? exception,
  }) {
    return NotesState(
      isMultiSelectionMode: isMultiSelectionMode ?? this.isMultiSelectionMode,
      isGridView: isGridView ?? this.isGridView,
      noteStatus: noteStatus ?? this.noteStatus,
      notes: notes ?? this.notes,
      selectedNotes: selectedNotes ?? this.selectedNotes,
      exception: exception ?? this.exception,
    );
  }

  List<Note> get pinnedNotes {
    return notes.where((note) => note.pinStatus).toList();
  }

  List<Note> get unPinnedNotes {
    return notes.where((note) => !note.pinStatus).toList();
  }

  //   return notes,
  // }
}
