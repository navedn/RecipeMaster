import 'package:flutter/material.dart';
import 'database_helper.dart'; // Import your DatabaseHelper
import 'HomeScreen.dart'; // Import HomeScreen from HomeScreen.dart
import 'shopping_list_screen.dart';
import 'planner_screen.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(dbHelper: dbHelper),
        '/shopping': (context) => ShoppingListScreen(),
        '/planner': (context) => PlannerScreen(),
        '/settings': (context) => Placeholder(),
      },
    );
  }
}
