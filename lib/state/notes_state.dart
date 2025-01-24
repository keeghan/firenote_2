import '../data/note.dart';

//state for notes Loading
enum NoteStatus { initial, loading, success, failure }
//state for actions [delete, pin, change color]
enum NoteActionStatus { none, loading, success, failure }

final class NotesState {
  final bool isMultiSelectionMode;
  final bool isGridView;
  final NoteStatus noteStatus;
  final NoteActionStatus noteActionStatus;
  final List<Note>? notes;
  final Set<Note> selectedNotes;
  final Exception? exception;

  NotesState({
    this.noteActionStatus = NoteActionStatus.none,
    this.isMultiSelectionMode = false,
    this.notes = null,
    this.selectedNotes = const <Note>{},
    this.exception = null,
    this.isGridView = false,
    this.noteStatus = NoteStatus.initial,
  });

  NotesState copyWith({
    bool? isMultiSelectionMode,
    bool? isGridView,
    NoteStatus? noteStatus,
    NoteActionStatus? noteActionStatus,
    List<Note>? notes,
    Set<Note>? selectedNotes,
    Exception? exception,
  }) {
    return NotesState(
      noteActionStatus: noteActionStatus ?? this.noteActionStatus,
      isMultiSelectionMode: isMultiSelectionMode ?? this.isMultiSelectionMode,
      isGridView: isGridView ?? this.isGridView,
      noteStatus: noteStatus ?? this.noteStatus,
      notes: notes ?? this.notes,
      selectedNotes: selectedNotes ?? this.selectedNotes,
      exception: exception ?? this.exception,
    );
  }

  List<Note> get pinnedNotes {
    if (notes == null) return [];
    return notes!.where((note) => note.pinStatus).toList();
  }

  List<Note> get unPinnedNotes {
    if (notes == null) return [];
    return notes!.where((note) => !note.pinStatus).toList();
  }

  //   return notes,
  // }
}
