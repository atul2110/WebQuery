import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LLM Project',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.blueGrey,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900], // Dark background for AppBar
          iconTheme: const IconThemeData(color: Colors.white), // White icons
          titleTextStyle:
              const TextStyle(color: Colors.white, fontSize: 20), // White text
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white24,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white70),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.cyan),
          ),
          labelStyle: TextStyle(color: Colors.white70),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.cyan),
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
