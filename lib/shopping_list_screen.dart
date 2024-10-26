import 'package:flutter/material.dart';

class ShoppingListScreen extends StatefulWidget {
  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<Map<String, dynamic>> shoppingList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;

    shoppingList = args != null ? List<Map<String, dynamic>>.from(args as List<Map<String, dynamic>>) : [];
  }

  void addNewShoppingItem() {
    setState(() {
      shoppingList.add({
        'entreeName': '',
        'ingredients': [],
      });
    });
  }

  void addIngredient(int index) {
    setState(() {
      shoppingList[index]['ingredients'].add({
        'name': '',
        'checked': false,
      });
    });
  }

  void toggleChecked(int entreeIndex, int ingredientIndex) {
    setState(() {
      shoppingList[entreeIndex]['ingredients'][ingredientIndex]['checked'] =
          !shoppingList[entreeIndex]['ingredients'][ingredientIndex]['checked'];
    });
  }

  void removeIngredient(int entreeIndex, int ingredientIndex) {
    setState(() {
      shoppingList[entreeIndex]['ingredients'].removeAt(ingredientIndex);
    });
  }

  void removeShoppingItem(int index) {
    setState(() {
      shoppingList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping List'),
      ),
      body: ListView.builder(
        itemCount: shoppingList.length,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    shoppingList[index]['entreeName'] = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Entree Name',
                  ),
                ),
                Column(
                  children: List.generate(
                    shoppingList[index]['ingredients'].length,
                    (ingredientIndex) {
                      return ListTile(
                        leading: Checkbox(
                          value: shoppingList[index]['ingredients'][ingredientIndex]['checked'] ?? false,
                          onChanged: (value) {
                            toggleChecked(index, ingredientIndex);
                          },
                        ),
                        title: TextField(
                          onChanged: (value) {
                            shoppingList[index]['ingredients'][ingredientIndex]['name'] = value;
                          },
                          decoration: InputDecoration(
                            labelText: 'Ingredient',
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            removeIngredient(index, ingredientIndex);
                          },
                        ),
                      );
                    },
                  ),
                ),
                TextButton(
                  onPressed: () => addIngredient(index),
                  child: Text('Add Ingredient'),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => removeShoppingItem(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewShoppingItem,
        child: Icon(Icons.add),
      ),
    );
  }
}
