import 'package:firenote_2/utils/utils.dart';
import 'package:flutter/material.dart';

import '../../data/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NoteCard({super.key, required this.note, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    Color cardColor = NoteColors.hexToColor(note.color);
    bool isTransparent = note.color == NoteColors.transparent;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isTransparent ? Colors.grey : cardColor,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                maxLines: 6,
                note.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
