import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_auth_manager.dart';
import 'auth_page.dart';
import 'utils/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppAuthManager()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Firenote',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const AuthPage(),
        );
      },
    );
  }
}

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
