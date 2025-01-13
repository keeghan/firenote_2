import 'package:firenote_2/app_auth_manager.dart';
import 'package:firenote_2/utils/fire_note_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

PreferredSizeWidget buildSelectionBar(
  BuildContext context,
  final VoidCallback? onColorTap,
  final VoidCallback? onDeleteTap,
  final VoidCallback? onPinTap,
  final VoidCallback? onDuplicateTap,
  final VoidCallback? onCancelTap,
  final int selectedCount,
) {
  return AppBar(
    key: const ValueKey('selectionBar'),
    backgroundColor: appBarColor,
    leading: Container(
      alignment: Alignment.center,
      child: Row(
        children: [
          IconButton(
            onPressed: onCancelTap,
            icon: const Icon(Icons.cancel, color: Colors.white),
          ),
          Text(
            '$selectedCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
    leadingWidth: 100,
    actions: [
      IconButton(
        icon: const Icon(Icons.palette_outlined, color: Colors.white),
        onPressed: onColorTap,
        tooltip: 'Change color',
      ),
      IconButton(
        icon: const Icon(Icons.push_pin_outlined, color: Colors.white),
        onPressed: onPinTap,
        tooltip: 'Pin note',
      ),
      IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.white),
        onPressed: onDeleteTap,
        tooltip: 'Delete',
      ),
      IconButton(
        icon: const Icon(Icons.control_point_duplicate, color: Colors.white),
        onPressed: onDuplicateTap,
        tooltip: 'Duplicate',
      ),
      IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.white),
        onPressed: () {
          // Show more options menu
        },
        tooltip: 'More options',
      ),
    ],
  );
}

// Widget _buildMoreOptionsSheet(BuildContext context) {
//   return Container(
//     color: const Color(0xFF1E1E1E),
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         ListTile(
//           leading: const Icon(Icons.label_outline, color: Colors.white),
//           title: const Text('Add label', style: TextStyle(color: Colors.white)),
//           onTap: () {
//             Navigator.pop(context);
//             // Handle add label
//           },
//         ),
//         ListTile(
//           leading: const Icon(Icons.copy, color: Colors.white),
//           title: const Text('Make a copy', style: TextStyle(color: Colors.white)),
//           onTap: () {
//             Navigator.pop(context);
//             // Handle make copy
//           },
//         ),
//         ListTile(
//           leading: const Icon(Icons.share, color: Colors.white),
//           title: const Text('Share', style: TextStyle(color: Colors.white)),
//           onTap: () {
//             Navigator.pop(context);
//             // Handle share
//           },
//         ),
//       ],
//     ),
//   );
// }

//Default search Bar for NotesScreen
PreferredSizeWidget buildDefaultNoteBar(
  bool isGridView,
  Function toggleGridView,
  Function showLogoutDialog,
) {
  return AppBar(
    backgroundColor: appBarColor,
    leading: IconButton(
      icon: const Icon(Icons.menu, color: Colors.white),
      onPressed: () {},
    ),
    title: const NotesSearchBar(),
    actions: [
      IconButton(
        icon: Icon(
          isGridView ? Icons.view_agenda : Icons.grid_view,
          color: Colors.white,
        ),
        onPressed: () {
          toggleGridView();
        },
        tooltip: isGridView ? 'Switch to list view' : 'Switch to grid view',
      ),
      //Show User Icon
      Consumer<AppAuthManager>(builder: (context, authManager, _) {
        if (authManager.loggedIn) {
          return InkWell(
            // Tap to logout
            onTap: () => showLogoutDialog,
            child: CircleAvatar(
                backgroundColor: const Color(0xFF00B894),
                child: Text(authManager.userChar, style: const TextStyle(color: Colors.white))),
          );
        } else {
          return SizedBox(
            width: 2,
          );
        }
      }),
      const SizedBox(width: 8),
    ],
  );
}

class NotesSearchBar extends StatelessWidget {
  const NotesSearchBar({super.key});

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
