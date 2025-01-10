import 'package:firenote_2/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/note_card.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  static const String _gridViewPrefKey = "isGridView";
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _getGridViewPref();
  }

  //Change gridView preference and persist it
  void _toggleView() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_gridViewPrefKey, !_isGridView);
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: const SearchBar(),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_agenda : Icons.grid_view,
              color: Colors.white,
            ),
            onPressed: _toggleView,
          ),
          const CircleAvatar(
            backgroundColor: Color(0xFF00B894),
            child: Text('K', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: NotesGrid(isGridView: _isGridView),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB8C7FF),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {},
      ),
    );
  }

  //Get gridview preference
  Future<void> _getGridViewPref() async {
    final prefs = await SharedPreferences.getInstance();
    _isGridView = prefs.getBool(_gridViewPrefKey) ?? true;
    setState(() {});
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search your notes',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}

class NotesGrid extends StatelessWidget {
  final bool isGridView;

  const NotesGrid({
    super.key,
    required this.isGridView,
  });

  @override
  Widget build(BuildContext context) {
    Widget noteListBuilder(BuildContext context, int index) {
      return Padding(
        padding: EdgeInsets.only(bottom: isGridView ? 0 : 16), // Conditional bottom padding
        child: NoteCard(
          note: sampelnotes[index],
          onTap: () {
            //TODO: navigate to EditNotesScreen
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
          itemCount: sampelnotes.length,
          itemBuilder: noteListBuilder,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
        ),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: noteListBuilder,
        itemCount: sampelnotes.length,
      );
    }
  }
}
