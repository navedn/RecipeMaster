import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'CardsScreen.dart'; // Import necessary screens for navigation
import 'planner_screen.dart'; // Import necessary screens for navigation
import 'FolderScreen.dart'; // Import FoldersScreen for navigation

class ShoppingListScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  ShoppingListScreen({required this.dbHelper, Key? key}) : super(key: key);

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<Map<String, dynamic>> groceryList = [];

  // Track the checked state locally
  List<bool> checkedState = [];

  int _selectedIndex = 1; // Set the default selected index to Shopping List

  @override
  void initState() {
    super.initState();
    _loadGroceryList();
  }

  Future<void> _loadGroceryList() async {
    // Use the passed dbHelper instance
    List<Map<String, dynamic>> items =
        await widget.dbHelper.getGroceryListItems();
    setState(() {
      groceryList = items;
      // Initialize checkedState based on the grocery list
      checkedState = items
          .map((item) => item['checked'] == 1)
          .toList(); // Update based on DB
    });
  }

  Future<void> _deleteGroceryItem(int id) async {
    await widget.dbHelper.deleteGroceryItem(id);
    _loadGroceryList(); // Refresh the grocery list after deletion
  }

  void _addGroceryItem(String itemName) async {
    if (itemName.isNotEmpty) {
      await widget.dbHelper.insertGroceryItem(itemName);
      _loadGroceryList(); // Refresh the UI
    }
  }

  void _editGroceryItem(int id, String newName) async {
    if (newName.isNotEmpty) {
      await widget.dbHelper.updateGroceryItem(id, newName);
      _loadGroceryList(); // Refresh the UI
    }
  }

  Future<void> _toggleItemChecked(int index) async {
    // Toggle the checked state
    final currentChecked = checkedState[index];
    setState(() {
      checkedState[index] = !currentChecked; // Update local state
    });

    // Update the database
    await widget.dbHelper.updateGroceryItemChecked(
      groceryList[index]['_id'],
      !currentChecked,
    );
  }

  // Show dialog for adding or editing grocery item
  Future<void> _showItemDialog({int? itemId, String? currentName}) async {
    final TextEditingController controller =
        TextEditingController(text: currentName);

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(itemId == null ? 'Add Item' : 'Edit Item'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Item Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(itemId == null ? 'Add' : 'Save'),
              onPressed: () {
                if (itemId == null) {
                  // Add new item
                  _addGroceryItem(controller.text);
                } else {
                  // Edit existing item
                  _editGroceryItem(itemId, controller.text);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to handle bottom navigation bar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => FoldersScreen(dbHelper: widget.dbHelper)),
        );
        break;
      case 1:
        // Already on the Shopping List screen; no navigation needed
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => PlannerScreen(dbHelper: widget.dbHelper)),
        );
        break;
      case 3:
        Navigator.pushReplacement(
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
        title: Text('Shopping List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showItemDialog(), // Show dialog to add new item
          ),
        ],
      ),
      body: groceryList.isEmpty
          ? Center(child: Text('No items in your grocery list.'))
          : ListView.builder(
              itemCount: groceryList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: checkedState[index], // Bind checkbox to local state
                    onChanged: (value) {
                      _toggleItemChecked(index); // Toggle checked state
                    },
                  ),
                  title: Text(
                    groceryList[index]['item_name'],
                    style: TextStyle(
                      decoration: checkedState[index]
                          ? TextDecoration
                              .lineThrough // Add strikethrough if checked
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showItemDialog(
                            itemId: groceryList[index]['_id'],
                            currentName: groceryList[index]['item_name'],
                          ); // Show dialog to edit existing item
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.black),
                        onPressed: () {
                          _deleteGroceryItem(groceryList[index]['_id']);
                        },
                      ),
                    ],
                  ),
                );
              },
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
