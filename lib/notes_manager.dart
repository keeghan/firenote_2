import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firenote_2/firebase_options.dart';
import 'package:firenote_2/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data/note.dart';

class NoteManager extends ChangeNotifier {
  FirebaseDatabase? _database;
  FirebaseAuth? _auth;
  DatabaseReference? _noteRef;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

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
    print('====Updaated======${note.id}======');

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
    if (note.color == "#000000") note.color = '#00FFFFFF';
      try {
        note.dateTimeString = getFormattedDateTime();
        note.id = 'note_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}';
        print('==========${note.id}======');
        await _noteRef?.child(note.id).set(note.toMap());
        return null;
      } catch (e) {
        return e.toString();
      }
  }

  // Undo delete note
  Future<String?> undoDeleteNote(Note note) async {
    try {
      await _noteRef?.child(note.id).set(note.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Delete note
  Future<String?> deleteNote(Note note) async {
    try {
      await _noteRef?.child(note.id).remove();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Stream of notes (optional, for real-time updates)
  Stream<List<Note>> get notesStream {
    if (_noteRef == null) {
      return Stream.error(
          StateError('Notes reference not initialized. Please check authentication status.'));
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
      _isLoading = true;
      notifyListeners();
      final userId = _auth?.currentUser?.uid;
      if (userId != null) {
        _noteRef = _database?.ref(userId);
        // force a refresh of the data
        await _noteRef?.get();
      }
    } catch (e) {
      print('Error refreshing notes: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
