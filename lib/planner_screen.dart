import 'package:flutter/material.dart';

class PlannerScreen extends StatefulWidget {
  @override
  _PlannerScreenState createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  List<Map<String, dynamic>> plannerEntries = [];

  void addNewPlannerEntry() {
    setState(() {
      plannerEntries.add({
        'date': '',
        'mealPlan': '',
        'ingredients': [],  
      });
    });
  }

  void generateShoppingList() {
    List<Map<String, dynamic>> shoppingList = [];
    for (var entry in plannerEntries) {
      if (entry['mealPlan'].isNotEmpty) {
        shoppingList.add({
          'entreeName': entry['mealPlan'],
          'ingredients': entry['ingredients'], 
        });
      }
    }

    Navigator.pushNamed(context, '/shopping', arguments: shoppingList);
  }

  void removePlannerEntry(int index) {
    setState(() {
      plannerEntries.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planner'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: generateShoppingList,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: plannerEntries.length,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    plannerEntries[index]['date'] = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Date',
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    plannerEntries[index]['mealPlan'] = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Meal Plan',
                  ),
                  maxLines: 3,
                ),
                Column(
                  children: List.generate(
                    plannerEntries[index]['ingredients'].length,
                    (ingredientIndex) {
                      return ListTile(
                        title: TextField(
                          onChanged: (value) {
                            plannerEntries[index]['ingredients'][ingredientIndex] = value;
                          },
                          decoration: InputDecoration(labelText: 'Ingredient'),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              plannerEntries[index]['ingredients'].removeAt(ingredientIndex);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      plannerEntries[index]['ingredients'].add('');
                    });
                  },
                  child: Text('Add Ingredient'),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => removePlannerEntry(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewPlannerEntry,
        child: Icon(Icons.add),
      ),
    );
  }
}
