import 'package:flutter/material.dart';
import 'database_helper.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping List'),
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
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteGroceryItem(groceryList[index]['_id']);
                    },
                  ),
                );
              },
            ),
    );
  }
}
