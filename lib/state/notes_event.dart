import '../data/note.dart';

abstract class NotesEvent {
  const NotesEvent();

  List<Object> get props => [];
}

class InitializeNotes extends NotesEvent {}

class LoadNotes extends NotesEvent {}

class ToggleGridView extends NotesEvent {}

class OnLongPress extends NotesEvent {
  final Note pressedNote;

  OnLongPress(this.pressedNote);
  @override
  List<Object> get props => [pressedNote];
}

class OnNoteTap extends NotesEvent {
  final Note tappedNote;

  OnNoteTap(this.tappedNote);
  @override
  List<Object> get props => [tappedNote];
}

class ClearSelection extends NotesEvent {}

class DeleteNotes extends NotesEvent {}

class ToggleNotesPin extends NotesEvent {}

class DuplicateNotes extends NotesEvent {}

class ChangeNotesColor extends NotesEvent {
  final String color;

  ChangeNotesColor(this.color);
}

class SaveNote extends NotesEvent {
  final Note note;
  final bool isNewNote;
  SaveNote(this.note, {this.isNewNote = false});
}

//EditScreen actions
class UpdateNote extends NotesEvent {
  final List<Note> notes;
  UpdateNote(this.notes);
}
