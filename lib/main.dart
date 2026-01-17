import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firenote_2/firebase_options.dart';
import 'package:firenote_2/state/authentication_bloc.dart';
import 'package:firenote_2/state/notes_bloc.dart';
import 'package:firenote_2/ui/edit_note_screen.dart';
import 'package:firenote_2/ui/password_recovery_screen.dart';
import 'package:firenote_2/ui/sign_in_screen.dart';
import 'package:firenote_2/ui/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'data/note.dart';
import 'ui/notes_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final authBloc = AuthenticationBloc();
  final notesBloc = NotesBloc();
  //force go router to referesh on authchanges
  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user != null) {
      await user.getIdToken(true);
      // Small delay to ensure token propagation to database
      await Future.delayed(const Duration(milliseconds: 500));
    }
    router.refresh();
  });
  runApp(MyApp(authBloc: authBloc, notesBloc: notesBloc));
}

class MyApp extends StatelessWidget {
  final AuthenticationBloc authBloc;
  final NotesBloc notesBloc;
  const MyApp({super.key, required this.authBloc, required this.notesBloc});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(create: (context) => authBloc),
        BlocProvider<NotesBloc>(create: (context) => notesBloc)
      ],
      child: MaterialApp.router(
        routerConfig: router,
        title: 'Firenote',
        theme: lightTheme,
        darkTheme: darkTheme,
        //  themeMode: themeProvider.themeMode,
      ),
    );
  }
}

//Navigation Setup
final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  redirect: (BuildContext context, GoRouterState state) {
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final bool isAuthRoute = state.uri.toString().startsWith('/auth');
    if (!isLoggedIn && !isAuthRoute) {
      return '/auth/signin';
    }
    if (isLoggedIn && isAuthRoute) {
      return '/notes';
    }
    return null;
  },
  routes: [
    // Auth route with sub-routes for login, signup, and recovery
    GoRoute(
      path: '/auth',
      builder: (context, state) => const SignInScreen(), // Default to sign in
      routes: [
        GoRoute(
          path: 'signin',
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: 'signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: 'recover',
          builder: (context, state) => const PasswordRecoveryScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/notes',
      builder: (context, state) => const NotesScreen(),
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            final note = state.extra as Note?;
            return EditNoteScreen(note: note);
          },
        ),
      ],
    ),
    // Redirect root to notes
    GoRoute(
      path: '/',
      redirect: (_, __) => '/notes',
    ),
  ],
);

//Themes for easy Access
final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Colors.purple,
    secondary: Colors.purpleAccent,
    tertiary: Colors.deepPurple,
    surface: Colors.grey[50]!,
    error: Colors.red[700]!,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.white,
    onSurface: Colors.black87,
    onError: Colors.white,
  ),
  useMaterial3: true,
);

final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.dark(
    primary: Colors.purple[300]!, // Lighter shade for dark theme
    secondary: Colors.purpleAccent[100]!,
    tertiary: Colors.deepPurple[200],
    surface: Colors.black,
    error: Colors.red[300]!,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onTertiary: Colors.black,
    onSurface: Colors.white,
    onError: Colors.black,
  ),
  useMaterial3: true,
);
