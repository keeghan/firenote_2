import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/note.dart';

class Utils {
  static String encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceTint,
        content: Text(message, textAlign: TextAlign.center),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }
}

class ValidationUtils {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

// Color getNoteColor(String colorString) {
//   switch (colorString) {
//     case NoteColors.red:
//       return Colors.red;
//     case NoteColors.COLOR_BLUE:
//       return Colors.blue;
//     case NoteColors.COLOR_ORANGE:
//       return Colors.orange;
//     case NoteColors.COLOR_VIOLET:
//       return Colors.purple;
//     case NoteColors.COLOR_GREEN:
//       return Colors.green;
//     case NoteColors.COLOR_BROWN:
//       return Colors.brown;
//     case NoteColors.COLOR_DARK_GREY:
//       return Colors.grey.shade800;
//     case NoteColors.COLOR_TRANSPARENT:
//       return Colors.transparent;
//     default:
//       return Colors.black;
//   }
// }

class NoteColors {
  static const String red = "#880000";
  static const String blue = "#FF01579B";
  static const String orange = "#FFE65100";
  static const String violet = "#8f4f8f";
  static const String green = "#38761d";
  static const String brown = "#310c0c";
  static const String darkGrey = "#4c4c4c";
  static const String transparent = "#00FFFFFF";

  // Method to convert hex color string to Color object
  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse('0x$hex'));
  }
}

const String noteIdPattern = "yyyyMMddHHmmssSS";
const String noteTimePatter = "yyyy-MM-dd HH:mm:ss SSSS z";

//Sample notes
List<Note> sampelnotes = [
  Note(
    id: "note_2023022721392822",
    title: "why?",
    message: "I delete all my old note.",
    color: "#00FFFFFF",
    pinStatus: false,
    dateTimeString: "2024-12-15 15:42:16 3402 GMT",
  ),
  Note(
    id: "note_2023022721395531",
    title: "Package ",
    message:
        "TINDE\nFRAGILE SCREEM\nHANDLE WITH CARE\nKOJO KAKRABA EGHAN\nIT SUPPORT AND TRAINING CENTER, UCC.\n0553125141\nCAPE COAST.\n",
    color: "#38761d",
    pinStatus: true,
    dateTimeString: "2024-12-24 11:48:24 1909 GMT",
  ),
  Note(
    id: "note_2023022721403692",
    title: "pinned",
    message: "There is now a new problem.\nThe pinned list is not working ",
    color: "#880000",
    pinStatus: false,
    dateTimeString: "2023-09-18 21:18:04 7976 GMT",
  ),
  Note(
    id: "note_2023091818460556",
    title: "This is a new note",
    message:
        "I am writing a new note to fill in the spaces before taking a screenshot for the read.me\nI think i am going to choose the green color",
    color: "#FFE65100",
    pinStatus: true,
    dateTimeString: "2023-09-18 18:46:05 5583 GMT",
  ),
  Note(
    id: "note_2023091819403244",
    title: "adsfdfadfss",
    message: "Hello this is a enw note",
    color: "#00FFFFFF",
    pinStatus: true,
    dateTimeString: "2023-09-18 19:40:32 4471 GMT",
  ),
  Note(
    id: "note_2023091819403715",
    title: "adsfdfadfss",
    message: "Hello this is a enw note",
    color: "#00FFFFFF",
    pinStatus: true,
    dateTimeString: "2023-09-18 19:40:37 1527 GMT",
  ),
  Note(
    id: "note_2023091819404438",
    title: "adsfdfadfss",
    message: "Hello this is a enw note",
    color: "#00FFFFFF",
    pinStatus: false,
    dateTimeString: "2023-09-18 19:40:44 3882 GMT",
  ),
  Note(
    id: "note_2023091916575277",
    title: "pinned",
    message: "There is now a new problem.\nThe pinned list is not w",
    color: "#FFE65100",
    pinStatus: false,
    dateTimeString: "2023-09-19 16:58:01 2515 GMT",
  ),
  Note(
    id: "note_2024072113044074",
    title: "Maybe I am",
    message: "Hello is this still working",
    color: "#38761d",
    pinStatus: true,
    dateTimeString: "2024-07-21 13:04:40 7345 GMT",
  ),
];
