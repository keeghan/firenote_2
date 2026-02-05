import 'package:firenote_2/data/note.dart';
import 'package:firenote_2/ui/widgets/note_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

//Widget to Show a list of notes in a grid or list form
class NotesGrid extends StatelessWidget {
  final bool isGridView;
  final List<Note> notesList;
  final void Function(Note note) onTap;
  final void Function(Note note) onLongPress;
  final Set<String> selectedNotes;

  const NotesGrid({
    super.key,
    required this.isGridView,
    required this.notesList,
    required this.onTap,
    required this.onLongPress,
    required this.selectedNotes,
  });

  @override
  Widget build(BuildContext context) {
    List<Note> pinned = notesList.where((note) => note.pinStatus).toList();
    List<Note> unPinned = notesList.where((note) => !note.pinStatus).toList();

    Widget sectionHeader(String title) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w500)
              .copyWith(color: Colors.grey),
        ),
      );
    }

    Widget noteListBuilder(Note note) {
      return _AnimatedNoteItem(
        key: ValueKey(note.id),
        child: Padding(
          padding: EdgeInsets.only(bottom: isGridView ? 0 : 16),
          child: NoteCard(
            note: note,
            //Pass Note to be edited
            onTap: () => onTap(note),
            onLongPress: () => onLongPress(note),
            isSelected: selectedNotes.contains(note.id),
          ),
        ),
      );
    }

    if (isGridView) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: CustomScrollView(
          slivers: [
            if (pinned.isNotEmpty) ...[
              SliverToBoxAdapter(child: sectionHeader('pinned')),
              SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                itemBuilder: (context, index) => noteListBuilder(pinned[index]),
                childCount: pinned.length,
              ),
            ],
            if (unPinned.isNotEmpty) ...[
              SliverToBoxAdapter(child: sectionHeader('others')),
              SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                itemBuilder: (context, index) => noteListBuilder(unPinned[index]),
                childCount: unPinned.length,
              ),
            ]
          ],
        ),
      );
    } else {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (pinned.isNotEmpty) ...[
            sectionHeader('Pinned'),
            ...pinned.map((note) => noteListBuilder(note)),
          ],
          if (unPinned.isNotEmpty) ...[
            sectionHeader('Others'),
            ...unPinned.map((note) => noteListBuilder(note)),
          ],
        ],
      );
    }
  }
}

class _AnimatedNoteItem extends StatefulWidget {
  final Widget child;

  const _AnimatedNoteItem({super.key, required this.child});

  @override
  State<_AnimatedNoteItem> createState() => _AnimatedNoteItemState();
}

class _AnimatedNoteItemState extends State<_AnimatedNoteItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _opacity = Tween<double>(begin: 0, end: 1).animate(curve);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(curve);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
