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
        ? Colors.transparent // resolved to surface color in build
        : widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Resolve transparent selection to the theme surface color
    final effectiveSelected =
        _selectedColor == Colors.transparent ? surfaceColor : _selectedColor;

    final colorList = widget.availableColors.map((colorHex) {
      Color color = hexToColor(colorHex);
      if (colorHex == NoteColors.transparent) color = surfaceColor;
      return GestureDetector(
        onTap: () {
          setState(() => _selectedColor = colorHex == NoteColors.transparent
              ? Colors.transparent
              : color);
          widget.onColorChanged(colorHex);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (widget.isGridView && colorHex == NoteColors.transparent)
                ? Colors.transparent
                : color,
            border: widget.isGridView
                ? (colorHex == NoteColors.transparent
                    ? Border.all(color: Colors.grey, width: 2)
                    : null)
                : Border.all(
                    color: isDark ? Colors.white : Colors.grey,
                    width: 2,
                  ),
          ),
        ),
      );
    }).toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: widget.isGridView ? EdgeInsets.all(8) : const EdgeInsets.fromLTRB(16, 32, 16, 32),
      decoration: BoxDecoration(
        borderRadius: widget.isGridView ? BorderRadius.all(Radius.circular(12)) : null,
        color: widget.isGridView
            ? (isDark ? Colors.black.withAlpha(200) : Colors.grey[300]!)
            : effectiveSelected,
        border: Border.all(color: Colors.grey, width: 1),
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
