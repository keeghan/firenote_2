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
  final Note newNote;
  SaveNote(this.newNote);

  @override
  List<Object> get props => [newNote];
}

//EditScreen actions
class UpdateNote extends NotesEvent {
  final Note upDatedNote;
  UpdateNote(this.upDatedNote);

  @override
  List<Object> get props => [upDatedNote];
}

class CleanupNotes extends NotesEvent {}

class SearchNotes extends NotesEvent {
  final String query;
  SearchNotes(this.query);

  @override
  List<Object> get props => [query];
}
