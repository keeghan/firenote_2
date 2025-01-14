import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class NoteColorPicker extends StatefulWidget {
  final List<String> availableColors = [
    NoteColors.transparent,
    NoteColors.red,
    NoteColors.blue,
    NoteColors.orange,
    NoteColors.violet,
    NoteColors.green,
    NoteColors.brown,
    NoteColors.darkGrey,
  ];
  final Color initialColor;
  final ValueChanged<String> onColorChanged;
  final bool isGridView;

  NoteColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
    required this.isGridView,
  });

  @override
  State<NoteColorPicker> createState() => _NoteColorPickerState();
}

class _NoteColorPickerState extends State<NoteColorPicker> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor == hexToColor(NoteColors.transparent)
        ? Colors.black
        : widget.initialColor;
  }

  //Use black in app but transfer traansparent to Database
  //for native app interoperability
  @override
  Widget build(BuildContext context) {
    final colorList = widget.availableColors.map((colorHex) {
      Color color = hexToColor(colorHex);
      if (colorHex == NoteColors.transparent) color = Colors.black;
      return GestureDetector(
        onTap: () {
          setState(() => _selectedColor = color);
          widget.onColorChanged(colorHex);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            //Different color options if used as grid in NoteScreen or list
            // in EditNoteScreen
            color: (widget.isGridView && colorHex == NoteColors.transparent)
                ? Colors.transparent
                : color,
            border: (widget.isGridView && colorHex == NoteColors.transparent)
                ? Border.all(color: Colors.grey[800]!, width: 2)
                : null,
          ),
        ),
      );
    }).toList();

    //List for NoteScreen or List for EditNoteScreen
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: widget.isGridView ? EdgeInsets.all(8) : const EdgeInsets.fromLTRB(16, 32, 16, 32),
      decoration: BoxDecoration(
        borderRadius: widget.isGridView ? BorderRadius.all(Radius.circular(12)) : null,
        color: widget.isGridView ? Colors.black.withAlpha(200) : _selectedColor,
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: widget.isGridView
          ? GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: colorList,
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: colorList,
              ),
            ),
    );
  }
}
