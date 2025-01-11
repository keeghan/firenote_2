import 'package:firenote_2/data/note.dart';
import 'package:firenote_2/ui/edit_note_screen.dart';
import 'package:firenote_2/ui/widgets/note_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

//Widget to Show a list of notes in a grid or list form
class NotesGrid extends StatelessWidget {
  final bool isGridView;
  final List<Note> notesList;

  const NotesGrid({
    super.key,
    required this.isGridView,
    required this.notesList,
  });

  @override
  Widget build(BuildContext context) {
    Widget noteListBuilder(BuildContext context, int index) {
      return Padding(
        padding: EdgeInsets.only(bottom: isGridView ? 0 : 16),
        child: NoteCard(
          note: notesList[index],
          onTap: () {
            //Pass Note to be edited
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditNoteScreen(note: notesList[index]),
              ),
            );
          },
          onLongPress: () {
            //TODO: bring up quick action menu
          },
        ),
      );
    }

    if (isGridView) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          itemCount: notesList.length,
          itemBuilder: noteListBuilder,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
        ),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: noteListBuilder,
        itemCount: notesList.length,
      );
    }
  }
}
