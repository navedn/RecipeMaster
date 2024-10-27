import 'package:flutter/material.dart';
import 'package:recipemaster/FolderScreen.dart';
import 'database_helper.dart';
import 'shopping_list_screen.dart';
import 'planner_screen.dart';
import 'FolderScreen.dart';

class SettingsScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const SettingsScreen({Key? key, required this.dbHelper}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => FoldersScreen(
                  dbHelper: widget.dbHelper)), // Replace with your HomeScreen
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ShoppingListScreen(dbHelper: widget.dbHelper)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => PlannerScreen(dbHelper: widget.dbHelper)),
        );
        break;
      case 3:
        // Stay on Settings screen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Implement Reset to Defaults functionality here
                print('Reset to Defaults pressed');
              },
              child: Text('Reset to Defaults'),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Implement Clear Cache functionality here
              print('Clear Cache pressed');
            },
            child: Text('Clear Cache'),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Shopping'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Planner'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
