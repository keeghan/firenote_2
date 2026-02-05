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
  final String searchQuery;

  NotesState({
    this.noteActionStatus = NoteActionStatus.none,
    this.isMultiSelectionMode = false,
    this.notes,
    this.selectedNotes = const <Note>{},
    this.exception,
    this.isGridView = false,
    this.noteStatus = NoteStatus.initial,
    this.searchQuery = '',
  });

  NotesState copyWith({
    bool? isMultiSelectionMode,
    bool? isGridView,
    NoteStatus? noteStatus,
    NoteActionStatus? noteActStatus,
    List<Note>? notes,
    Set<Note>? selectedNotes,
    Exception? exception,
    String? searchQuery,
  }) {
    return NotesState(
      noteActionStatus: noteActStatus ?? noteActionStatus,
      isMultiSelectionMode: isMultiSelectionMode ?? this.isMultiSelectionMode,
      isGridView: isGridView ?? this.isGridView,
      noteStatus: noteStatus ?? this.noteStatus,
      notes: notes ?? this.notes,
      selectedNotes: selectedNotes ?? this.selectedNotes,
      exception: exception ?? this.exception,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Note> get filteredNotes {
    if (notes == null) return [];
    if (searchQuery.isEmpty) return notes!;
    final query = searchQuery.toLowerCase();
    return notes!.where((note) {
      return note.title.toLowerCase().contains(query) ||
          note.message.toLowerCase().contains(query);
    }).toList();
  }

  List<Note> get pinnedNotes {
    return filteredNotes.where((note) => note.pinStatus).toList();
  }

  List<Note> get unPinnedNotes {
    return filteredNotes.where((note) => !note.pinStatus).toList();
  }

  //   return notes,
  // }
}
