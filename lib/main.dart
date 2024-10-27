import 'package:flutter/material.dart';
import 'database_helper.dart'; // Import your DatabaseHelper
import 'FolderScreen.dart';
import 'shopping_list_screen.dart';
import 'planner_screen.dart';

import 'package:flutter/material.dart';

class AppColorTheme {
  static const Color primary = Color(0xFF1A73E8); // Deep Blue
  static const Color secondary = Color(0xFFFF6F61); // Coral
  static const Color background = Color(0xFFF5F5F5); // Light Gray
  static const Color surface = Color(0xFFFFFFFF); // White

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      appBarTheme: AppBarTheme(
        color: primary,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),
      textTheme: TextTheme(
        headlineSmall: TextStyle(
            fontSize: 20.0, fontWeight: FontWeight.bold, color: primary),
        bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black),
        bodyLarge: TextStyle(fontSize: 14.0, color: Colors.grey[1000]),
      ),
      iconTheme: IconThemeData(color: primary),
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
      ).copyWith(surface: background),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper();
  await dbHelper.init();

  runApp(MyApp(dbHelper: dbHelper));
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper;

  const MyApp({Key? key, required this.dbHelper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe and Meal Planner App',
      theme: AppColorTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => FoldersScreen(dbHelper: dbHelper),
        '/shopping': (context) => ShoppingListScreen(dbHelper: dbHelper),
        '/planner': (context) => PlannerScreen(dbHelper: dbHelper),
        '/settings': (context) => Placeholder(),
      },
    );
  }
}
