import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firenote_2/data/note.dart';
import 'package:firenote_2/state/notes_event.dart';
import 'package:firenote_2/state/notes_state.dart';
import 'package:firenote_2/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../utils/preference_service.dart';

// Additional Events
class ResetNotesActionState extends NotesEvent {}

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference? _noteRef;
  StreamSubscription? _notesSubscription;
  final _uuid = const Uuid();

  NotesBloc() : super(NotesState()) {
    on<InitializeNotes>(_onInitialize);
    on<LoadNotes>(_onLoadNotes);
    on<ToggleGridView>(_onToggleGridView);
    on<OnLongPress>(_onLongPress);
    on<OnNoteTap>(_onNoteTap);
    on<ClearSelection>(_onClearSelection);
    on<ChangeNotesColor>(_onChangeNotesColor);
    on<DeleteNotes>(_onDeleteNotes);
    on<ToggleNotesPin>(_onToggleNotesPin);
    on<DuplicateNotes>(_onDuplicateNotes);
    on<UpdateNote>(_onNotesUpdated);
    on<SaveNote>(_onSaveNote);
    on<ResetNotesActionState>((event, emit) {
      emit(state.copyWith(
        exception: null,
        noteActionStatus: NoteActionStatus.none,
      ));
    });

    // Initialize when created
    add(InitializeNotes());
  }

  Future<void> _onInitialize(InitializeNotes event, Emitter<NotesState> emit) async {
    emit(state.copyWith(noteStatus: NoteStatus.loading));
    try {
      final isGridView = await PreferencesService.getIsGridView(); // Get saved preference
      emit(state.copyWith(isGridView: isGridView, noteStatus: NoteStatus.loading));
      add(LoadNotes());
    } catch (e) {
      emit(state.copyWith(noteStatus: NoteStatus.failure, exception: e as Exception));
    }
  }

  //Check internet first
  Future<void> _setupNoteRef() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      _noteRef = _database.ref(userId);
    } else {
      throw Exception('User not authenticated');
    }
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    emit(state.copyWith(noteStatus: NoteStatus.loading));
    try {
      await _setupNoteRef();
      await _notesSubscription?.cancel();
      //check internet connection
      await InternetAddress.lookup('example.com');
      final noteStream = _noteRef?.onValue ?? Stream.empty();

      // Using emit.forEach to handle the stream events
      await emit.forEach(
        noteStream,
        onData: (event) {
          try {
            final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
            if (data == null) {
              emit(state.copyWith(
                exception: Exception("No notes"),
                noteStatus: NoteStatus.failure,
                notes: null,
              ));
              return state;
            }

            final notes =
                data.values.map((value) => Note.fromMap(Map<String, dynamic>.from(value))).toList();
            notes.sort((a, b) => b.dateTimeString.compareTo(a.dateTimeString));

            emit(state.copyWith(noteStatus: NoteStatus.success, notes: notes));
          } catch (e) {
            emit(state.copyWith(
              exception: Exception(e.toString()),
              noteStatus: NoteStatus.failure,
              notes: null,
            ));
          }
          return state;
        },
        onError: (error, stackTrace) {
          emit(state.copyWith(
            exception: Exception(error.toString()),
            noteStatus: NoteStatus.failure,
            notes: null,
          ));
          return state;
        },
      );
    } catch (e) {
      emit(state.copyWith(
        exception: e is SocketException ? Exception('check internet connection') : e as Exception,
        noteStatus: NoteStatus.failure,
        notes: e is SocketException ? null : state.notes,
      ));
    }
  }

  Future<void> _onDuplicateNotes(DuplicateNotes event, Emitter<NotesState> emit) async {
    try {
      final duplicateActions = state.selectedNotes.map((note) {
        note.id = 'note_${_uuid.v1()}';
        return _noteRef!.child(note.id).set(note.toMap());
      });
      await Future.wait(duplicateActions);
      emit(state.copyWith(
          noteStatus: NoteStatus.success, selectedNotes: {}, isMultiSelectionMode: false));
    } catch (e) {
      _onActionFailure(e, event, emit);
    }
  }

  Future<void> _onChangeNotesColor(ChangeNotesColor event, Emitter<NotesState> emit) async {
    try {
      final colorChanges = state.selectedNotes.map(
        (note) => _noteRef!.child(note.id).update({'color': event.color}),
      );
      await Future.wait(colorChanges);
      emit(state.copyWith(
          noteStatus: NoteStatus.success, selectedNotes: {}, isMultiSelectionMode: false));
    } catch (e) {
      _onActionFailure(e, event, emit);
    }
  }

  Future<void> _onToggleNotesPin(ToggleNotesPin event, Emitter<NotesState> emit) async {
    try {
      final toggleActions = state.selectedNotes.map(
        (note) => _noteRef!.child(note.id).update({'pinStatus': !note.pinStatus}),
      );
      await Future.wait(toggleActions);
      emit(state.copyWith(
          noteStatus: NoteStatus.success, selectedNotes: {}, isMultiSelectionMode: false));
    } catch (e) {
      _onActionFailure(e, event, emit);
    }
  }

  Future<void> _onDeleteNotes(DeleteNotes event, Emitter<NotesState> emit) async {
    emit(state.copyWith(noteActionStatus: NoteActionStatus.loading));
    try {
      final deleteFutures = state.selectedNotes.map((note) => _noteRef!.child(note.id).remove());
      await Future.wait(deleteFutures);
      emit(state.copyWith(
          noteStatus: NoteStatus.success, selectedNotes: {}, isMultiSelectionMode: false));
    } catch (e) {
      _onActionFailure(e, event, emit);
    }
  }

  void _onLongPress(OnLongPress event, Emitter<NotesState> emit) {
    if (state.isMultiSelectionMode) return;
    //first selected
    final updatedSelection = Set<Note>.from(state.selectedNotes)..add(event.pressedNote);
    emit(state.copyWith(isMultiSelectionMode: true, selectedNotes: updatedSelection));
    if (state.selectedNotes.length > 1) throw "Selection Error: not first selection";
  }

  //if note selected Note remove, otherwise add
  //if not in selectionMode navigate
  void _onNoteTap(OnNoteTap event, Emitter<NotesState> emit) {
    if (state.isMultiSelectionMode) {
      if (state.selectedNotes.contains(event.tappedNote)) {
        //remove note
        final updatedSelection = Set<Note>.from(state.selectedNotes)..remove(event.tappedNote);
        //is last note is selection unselected, disable selection
        if (updatedSelection.isEmpty) {
          emit(state.copyWith(selectedNotes: {}, isMultiSelectionMode: false));
        } else {
          emit(state.copyWith(selectedNotes: updatedSelection));
        }
      } else {
        //is not already selected,so make selection
        final updatedSelection = Set<Note>.from(state.selectedNotes)..add(event.tappedNote);
        emit(state.copyWith(selectedNotes: updatedSelection));
      }
    } else {
      //signal navigation to NotesEdit
      throw Exception('not is multiselect mode,go back');
    }
  }

  void _onClearSelection(ClearSelection event, Emitter<NotesState> emit) {
    emit(state.copyWith(selectedNotes: {}, isMultiSelectionMode: false));
  }

  void _onToggleGridView(ToggleGridView event, Emitter<NotesState> emit) async {
    await PreferencesService.setIsGridView(!state.isGridView);
    final updatedValue = await PreferencesService.getIsGridView();
    emit(state.copyWith(isGridView: updatedValue));
  }

  @override
  Future<void> close() {
    _notesSubscription?.cancel();
    return super.close();
  }

  //internal helper method to cleanup
  void _onActionFailure(e, NotesEvent event, Emitter<NotesState> emit) {
    emit(state.copyWith(noteActionStatus: NoteActionStatus.failure, exception: e as Exception));
  }

  //=========== EditScreen Events =============
  Future<void> _onSaveNote(SaveNote event, Emitter<NotesState> emit) async {
    emit(state.copyWith(exception: null, noteActionStatus: NoteActionStatus.loading));
    try {
      event.newNote.dateTimeString = getFormattedDateTime();
      event.newNote.id = 'note_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}';
      await _noteRef?.child(event.newNote.id).set(event.newNote.toMap());
      emit(state.copyWith(noteActionStatus: NoteActionStatus.success));
    } catch (e) {
      emit(state.copyWith(
        noteActionStatus: NoteActionStatus.failure,
        exception: e as Exception,
      ));
    }
  }

  Future<void> _onNotesUpdated(UpdateNote event, Emitter<NotesState> emit) async {
    emit(state.copyWith(exception: null, noteActionStatus: NoteActionStatus.loading));
    final note = event.upDatedNote;
    try {
      final noteObject = {
        'color': note.color,
        'dateTimeString': getFormattedDateTime(),
        'id': note.id,
        'message': note.message,
        'pinStatus': note.pinStatus,
        'title': note.title,
      };
      await _noteRef?.child(note.id).update(noteObject);
      emit(state.copyWith(noteActionStatus: NoteActionStatus.success));
    } catch (e) {
      emit(state.copyWith(
        noteActionStatus: NoteActionStatus.failure,
        exception: e as Exception,
      ));
    }
  }
}
