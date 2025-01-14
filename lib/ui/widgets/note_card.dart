import 'package:firenote_2/utils/utils.dart';
import 'package:flutter/material.dart';

import '../../data/note.dart';

//A card represent a single Note
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isSelected;

  const NoteCard(
      {super.key,
      required this.note,
      required this.onTap,
      required this.onLongPress,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    Color cardColor = hexToColor(note.color);
    bool isTransparent = note.color == NoteColors.transparent;
    Color borderColor;
    //blue border when selected otherwise grey or note's color
    borderColor = isSelected
        ? Colors.blueAccent
        : isTransparent
            ? Colors.grey
            : cardColor;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                overflow: TextOverflow.ellipsis,
                maxLines: 6,
                note.message,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
