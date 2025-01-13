import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

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

class NoteColors {
  static const String red = "#880000";
  static const String blue = "#FF01579B";
  static const String orange = "#FFE65100";
  static const String violet = "#8f4f8f";
  static const String green = "#38761d";
  static const String brown = "#310c0c";
  static const String darkGrey = "#4c4c4c";
  static const String transparent = "#00FFFFFF";
}

//Change noteColor to flutter Color Object
//ensures interability with exisiting database
Color hexToColor(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  return Color(int.parse('0x$hex'));
}

String colorToHex(Color color) {
  // ignore: deprecated_member_use
  String hex = color.value.toRadixString(16).toUpperCase();
  hex = hex.padLeft(8, '0');
  if (hex.startsWith('FF')) return '#${hex.substring(2)}';
  return '#$hex';
}

//Format DateTime String to match native(Firenote App)
String getFormattedDateTime() {
  tz.initializeTimeZones();
  final DateTime now = DateTime.now();
  final location = tz.local;
  // final tzDateTime = tz.TZDateTime.from(now, location);
  final tzAbbr = location.currentTimeZone.abbreviation;

  final String formatted = DateFormat("yyyy-MM-dd HH:mm:ss SSSS").format(now);
  return "$formatted $tzAbbr".toUpperCase();
}

DateTime parseFormattedDateTime(String dateTimeStr) {
  try {
    // Remove timezone abbreviation and trim any whitespace
    final dateTimePart = dateTimeStr.split(' ').sublist(0, 4).join(' ').trim();
    // Create formatter matching the input format
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss SSSS');
    // Parse the datetime string
    final dateTime = formatter.parse(dateTimePart);

    return dateTime;
  } catch (e) {
    throw FormatException(
        'Invalid datetime format. Expected format: "yyyy-MM-dd HH:mm:ss SSSS TZ"');
  }
}

String formatLastEdited(DateTime dateTime) {
  final now = DateTime.now();
  final duration = now.difference(dateTime).abs();

  if (duration.inDays >= 365) {
    return DateFormat('dd MMM yyyy').format(dateTime); // Use DateFormat
  } else if (duration.inDays >= 30) {
    return DateFormat('dd MMM').format(dateTime); // Use DateFormat
  } else if (duration.inDays >= 1) {
    return '${duration.inDays}d';
  } else if (duration.inHours >= 1) {
    return '${duration.inHours}h';
  } else {
    return '${duration.inMinutes}m';
  }
}



void showPersistentToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.grey,
      fontSize: 16.0
    );
  }

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
