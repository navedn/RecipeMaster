import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'RecipesScreen.dart';
import 'shopping_list_screen.dart'; // Import additional screens
import 'planner_screen.dart';

class HomeScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  HomeScreen({required this.dbHelper, Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Map<String, dynamic>>>? _categoriesFuture;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Load categories from the database
  void _loadCategories() {
    _categoriesFuture = widget.dbHelper.getCategories();
  }

  // Navigate to selected page
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on the Home screen; no navigation needed
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ShoppingListScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PlannerScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Placeholder()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Categories'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No Categories Found'));
                } else {
                  var categories = snapshot.data!;
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      var category = categories[index];
                      return ListTile(
                        title: Text(category[DatabaseHelper.categoryName]),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipesScreen(
                                categoryId: category[DatabaseHelper.categoryId],
                                categoryName:
                                    category[DatabaseHelper.categoryName],
                                dbHelper: widget.dbHelper,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
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
