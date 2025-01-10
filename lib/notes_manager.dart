import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firenote_2/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data/note.dart';

class NoteManager extends ChangeNotifier {
  late FirebaseDatabase _database;
  late FirebaseAuth _auth;
  late DatabaseReference _noteRef;

  NoteManager() {
    init();
  }

  Future<void> init() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      _database = FirebaseDatabase.instance;
      _auth = FirebaseAuth.instance;
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        _database.ref(userId);
      }
    } catch (e) {
      rethrow; 
    }
  }

  // Update existing note or just its color
  Future<String?> updateNote(Note note, {String color = ''}) async {
    try {
      final noteObject = {
        'color': color.isEmpty ? note.color : color,
        'dateTimeString': note.dateTimeString.toUpperCase(),
        'id': note.id,
        'message': note.message,
        'pinStatus': note.pinStatus,
        'title': note.title,
      };
      await _noteRef.child(note.id).update(noteObject);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Save new note
  Future<String?> saveNote(Note note) async {
    try {
      final now = DateTime.now();
      note.dateTimeString = DateFormat('yyyy-MM-dd HH:mm:ss').format(now).toUpperCase();
      note.id = 'note_${DateFormat('yyyyMMddHHmmss').format(now)}';
      await _noteRef.child(note.id).set(note.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Undo delete note
  Future<String?> undoDeleteNote(Note note) async {
    try {
      await _noteRef.child(note.id).set(note.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Delete note
  Future<String?> deleteNote(Note note) async {
    try {
      await _noteRef.child(note.id).remove();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Stream of notes (optional, for real-time updates)
  Stream<List<Note>> get notesStream {
    return _noteRef.onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
      if (data == null) return [];

      return data.values.map((value) => Note.fromMap(Map<String, dynamic>.from(value))).toList();
    });
  }
}
