import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firenote_2/firebase_options.dart';
import 'package:firenote_2/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'data/note.dart';

class NoteManager extends ChangeNotifier {
  FirebaseDatabase? _database;
  FirebaseAuth? _auth;
  DatabaseReference? _noteRef;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  static const initFailed = "Error: check internet and try again";
  static const streamError = 'Notes reference not initialized. Please check authentication status.';

  NoteManager() {
    init();
  }

  Future<void> init() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      _database = FirebaseDatabase.instance;
      _auth = FirebaseAuth.instance;
      await _setupNoteRef();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing NoteManager: $e');
      _isInitialized = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _setupNoteRef() async {
    final userId = _auth?.currentUser?.uid;
    if (userId != null && _database != null) {
      _noteRef = _database!.ref(userId);
    } else {
      _noteRef = null;
    }
  }

  // Update existing note or just its color
  Future<String?> updateNote(Note note) async {
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
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Save new note
  Future<String?> saveNote(Note note) async {
    try {
      note.dateTimeString = getFormattedDateTime();
      note.id = 'note_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}';
      await _noteRef?.child(note.id).set(note.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Stream of notes (optional, for real-time updates)
  Stream<List<Note>> get notesStream {
    if (_noteRef == null) {
      return Stream.error(StateError(streamError));
    }
    return _noteRef!.onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
      if (data == null) return [];

      final notes = data.values
          .map((value) => Note.fromMap(
                Map<String, dynamic>.from(value),
              ))
          .toList();

      notes.sort((a, b) => b.dateTimeString.compareTo(a.dateTimeString));
      return notes;
    });
  }

  Future<void> refreshNotes() async {
    if (_isLoading) return;
    try {
      setup();
      final userId = _auth?.currentUser?.uid;
      if (userId != null) {
        _noteRef = _database?.ref(userId);
        // force a refresh of the data
        await _noteRef?.get();
      }
    } catch (e) {
      rethrow;
    } finally {
      cleanUp();
    }
  }

  // Batch note duplication
  Future<String?> duplicateNotes(Set<Note> notes) async {
    if (!_isInitialized) return initFailed;
    setup();
    var uuid = Uuid();
    try {
      final duplicateActions = notes.map(
        (note) {
          note.id = 'note_${uuid.v1()}';
          return _noteRef!.child(note.id).set(note.toMap());
        },
      );
      await Future.wait(duplicateActions);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      cleanUp();
    }
  }

  //Batch noteColorChange
  Future<String?> changeNotesColor(Set<Note> notes, String newColor) async {
    if (!_isInitialized) return initFailed;
    setup();
    try {
      final colorChanges = notes.map(
        (note) => _noteRef!.child(note.id).update({'color': newColor}),
      );
      await Future.wait(colorChanges);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      cleanUp();
    }
  }

  //Batch pinStatus change
  Future<String?> togglePinStatuses(Set<Note> notes) async {
    if (!_isInitialized) return initFailed;
    setup();
    try {
      final toggleActions = notes.map(
        (note) => _noteRef!.child(note.id).update({'pinStatus': !note.pinStatus}),
      );
      await Future.wait(toggleActions);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      cleanUp();
    }
  }

  //Batch note deletion
  Future<String?> deleteNotes(Set<Note> notes) async {
    if (!_isInitialized) return initFailed;
    setup();
    try {
      final deleteFutures = notes.map((note) => _noteRef!.child(note.id).remove());
      await Future.wait(deleteFutures);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      cleanUp();
    }
  }

  //------------
  void setup() {
    _isLoading = true;
    notifyListeners();
  }

  void cleanUp() {
    _isLoading = false;
    notifyListeners();
  }
}
