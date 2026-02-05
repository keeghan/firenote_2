import 'package:firenote_2/state/authentication_bloc.dart';
import 'package:firenote_2/state/authentication_state.dart';
import 'package:firenote_2/state/notes_bloc.dart';
import 'package:firenote_2/state/notes_event.dart';
import 'package:firenote_2/state/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    backgroundColor: Theme.of(context).colorScheme.surface,
    leading: Container(
      alignment: Alignment.center,
      child: Row(
        children: [
          IconButton(
            onPressed: onCancelTap,
            icon: const Icon(Icons.close),
          ),
          Text(
            '$selectedCount',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
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
        icon: const Icon(Icons.palette_outlined),
        onPressed: onColorTap,
        tooltip: 'Change color',
      ),
      IconButton(
        icon: const Icon(Icons.push_pin_outlined),
        onPressed: onPinTap,
        tooltip: 'Pin note',
      ),
      IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDeleteTap,
        tooltip: 'Delete',
      ),
      IconButton(
        icon: const Icon(Icons.control_point_duplicate),
        onPressed: onDuplicateTap,
        tooltip: 'Duplicate',
      ),
      IconButton(
        icon: const Icon(Icons.more_vert),
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
  VoidCallback onLogout,
) {
  return AppBar(
    backgroundColor: Colors.transparent,
    leading: IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () {},
    ),
    title: const NotesSearchBar(),
    actions: [
      IconButton(
        icon: Icon(
          isGridView ? Icons.view_agenda : Icons.grid_view,
        ),
        onPressed: () {
          toggleGridView();
        },
        tooltip: isGridView ? 'Switch to list view' : 'Switch to grid view',
      ),
      BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, authState) {
          if (authState is AuthenticationSuccessState) {
            String initial = '';
            if (authState.user.displayName != null && authState.user.displayName!.isNotEmpty) {
              initial = authState.user.displayName![0];
            } else if (authState.user.email != null && authState.user.email!.isNotEmpty) {
              initial = authState.user.email![0];
            }

            return PopupMenuButton<String>(
              offset: const Offset(0, 48),
              onSelected: (value) {
                if (value == 'logout') {
                  onLogout();
                } else if (value == 'theme') {
                  context.read<ThemeCubit>().toggleTheme();
                }
              },
              itemBuilder: (context) {
                final isDark = context.read<ThemeCubit>().state == ThemeMode.dark;
                return [
                  PopupMenuItem<String>(
                    value: 'theme',
                    child: Row(
                      children: [
                        Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                        const SizedBox(width: 12),
                        Text(isDark ? 'Light mode' : 'Dark mode'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 12),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ];
              },
              child: CircleAvatar(
                backgroundColor: const Color(0xFF00B894),
                child: Text(
                  initial,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      const SizedBox(width: 8),
    ],
  );
}

class NotesSearchBar extends StatefulWidget {
  const NotesSearchBar({super.key});

  @override
  State<NotesSearchBar> createState() => _NotesSearchBarState();
}

class _NotesSearchBarState extends State<NotesSearchBar> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      context.read<NotesBloc>().add(SearchNotes(_controller.text));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = context.select<NotesBloc, String>(
      (bloc) => bloc.state.searchQuery,
    );

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _controller,
        style: TextStyle(color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Search your notes',
          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
                  onPressed: () => _controller.clear(),
                )
              : null,
        ),
      ),
    );
  }
}
