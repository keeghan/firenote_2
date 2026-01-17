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

  List<String> _extractUrls(String text) {
    final urlPattern = RegExp(
      r'https?://[^\s]+',
      caseSensitive: false,
    );
    final matches = urlPattern.allMatches(text);
    return matches.map((match) => match.group(0)!).toList();
  }

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

    final urls = _extractUrls(note.message);

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
              if (urls.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.5),
                      width: 1,
                    ),  
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.link,
                        size: 16,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          urls.first,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (urls.length > 1)
                        Text(
                          ' +${urls.length - 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
