import 'package:flutter/material.dart';
import 'shopping_list_screen.dart';
import 'planner_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe and Meal Planner App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/shopping': (context) => ShoppingListScreen(),
        '/planner': (context) => PlannerScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Text('Welcome to the Recipe and Meal Planner App!'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Shopping'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Planner'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/shopping');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/planner');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/settings');
          }
        },
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings Screen'),
      ),
      body: Center(
        child: Text('Settings will be available here.'),
      ),
    );
  }
}
