import 'package:flutter/material.dart';
import 'package:recipemaster/SettingsScreen.dart';
import 'database_helper.dart';
import 'FolderScreen.dart';
import 'shopping_list_screen.dart';

class PlannerScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const PlannerScreen({super.key, required this.dbHelper});

  @override
  _PlannerScreenState createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  Future<List<Map<String, dynamic>>>? _mealPlans;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _fetchMealPlans();
  }

  void _fetchMealPlans() {
    setState(() {
      _mealPlans = widget.dbHelper.getMealPlans();
    });
  }

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
        // Already on the Planner screen; no navigation needed
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SettingsScreen(
                  dbHelper:
                      widget.dbHelper)), // Replace with your Settings screen
        );
        break;
    }
  }

  Future<void> _addNewMealPlan() async {
    final TextEditingController dateController = TextEditingController();
    final TextEditingController mealTypeController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    final TextEditingController timeController = TextEditingController();

    final List<Map<String, dynamic>> recipeIds =
        await widget.dbHelper.getAllRecipeIds();
    List<Map<String, dynamic>> recipes = [];

    for (var recipe in recipeIds) {
      final recipeId = recipe[DatabaseHelper.cardId] as int;
      final recipeName = await widget.dbHelper.getMealNameById(recipeId);
      if (recipeName != null) {
        recipes.add({'id': recipeId, 'name': recipeName});
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        int? selectedRecipeId;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Add New Meal Plan"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(labelText: 'Date'),
                    ),
                    TextField(
                      controller: mealTypeController,
                      decoration: const InputDecoration(labelText: 'Meal Type'),
                    ),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(labelText: 'Time'),
                    ),
                    DropdownButton<int>(
                      value: selectedRecipeId,
                      hint: const Text('Select a Recipe'),
                      items: recipes.map<DropdownMenuItem<int>>((recipe) {
                        return DropdownMenuItem<int>(
                          value: recipe['id'],
                          child: Text(recipe['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRecipeId = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedRecipeId != null) {
                      debugPrint(
                          "Adding meal with recipe ID: $selectedRecipeId");

                      await widget.dbHelper.insertMealPlan(
                        date: dateController.text,
                        mealType: mealTypeController.text,
                        notes: notesController.text,
                        time: timeController.text,
                        recipeId: selectedRecipeId!,
                      );
                      _fetchMealPlans();
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a recipe')),
                      );
                    }
                  },
                  child: const Text("Add Meal"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteMealPlan(int mealPlannerId) async {
    debugPrint('Deleting Meal Plan with ID: $mealPlannerId'); // Add debug print
    await widget.dbHelper.deleteMealPlan(mealPlannerId);
    _fetchMealPlans(); // Refresh the meal plans
  }

  void _showDeleteConfirmationDialog(int mealPlannerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Meal Plan"),
          content:
              const Text("Are you sure you want to delete this meal plan?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                debugPrint('$mealPlannerId');
                await _deleteMealPlan(mealPlannerId);
                Navigator.of(context).pop(); // Close the dialog after deletion
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _showEditMealPlanDialog(Map<String, dynamic> mealPlan) {
    final mealId = mealPlan[DatabaseHelper.mealPlannerId];
    final TextEditingController dateController =
        TextEditingController(text: mealPlan[DatabaseHelper.mealPlannerDate]);
    final TextEditingController mealTypeController = TextEditingController(
        text: mealPlan[DatabaseHelper.mealPlannerMealType]);
    final TextEditingController notesController =
        TextEditingController(text: mealPlan[DatabaseHelper.mealPlannerNotes]);
    final TextEditingController timeController =
        TextEditingController(text: mealPlan[DatabaseHelper.mealPlannerTime]);

    // Fetch all recipes for the dropdown
    Future<List<Map<String, dynamic>>> fetchRecipes() async {
      final List<Map<String, dynamic>> recipeIds =
          await widget.dbHelper.getAllRecipeIds();
      List<Map<String, dynamic>> recipes = [];

      for (var recipe in recipeIds) {
        final recipeId = recipe[DatabaseHelper.cardId] as int;
        final recipeName = await widget.dbHelper.getMealNameById(recipeId);
        if (recipeName != null) {
          recipes.add({'id': recipeId, 'name': recipeName});
        }
      }
      return recipes;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        int? selectedRecipeId = mealPlan[
            DatabaseHelper.mealPlannerRecipeId]; // Set the initial value
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchRecipes(), // Fetch recipes asynchronously
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final recipes = snapshot.data!;
              return AlertDialog(
                title: const Text("Edit Meal Plan"),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: dateController,
                        decoration: const InputDecoration(labelText: 'Date'),
                      ),
                      TextField(
                        controller: mealTypeController,
                        decoration:
                            const InputDecoration(labelText: 'Meal Type'),
                      ),
                      TextField(
                        controller: notesController,
                        decoration: const InputDecoration(labelText: 'Notes'),
                      ),
                      TextField(
                        controller: timeController,
                        decoration: const InputDecoration(labelText: 'Time'),
                      ),
                      DropdownButton<int>(
                        value: selectedRecipeId,
                        hint: const Text('Select a Recipe'),
                        items: recipes.map<DropdownMenuItem<int>>((recipe) {
                          return DropdownMenuItem<int>(
                            value: recipe['id'],
                            child: Text(recipe['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRecipeId = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await widget.dbHelper.updateMealPlan(
                        mealId,
                        date: dateController.text,
                        mealType: mealTypeController.text,
                        recipeId: selectedRecipeId, // Include the new recipe ID
                        notes: notesController.text,
                        time: timeController.text,
                      );
                      _fetchMealPlans(); // Refresh the meal plans list
                      Navigator.of(context).pop();
                    },
                    child: const Text("Save"),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _mealPlans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No meal plans available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final mealPlan = snapshot.data![index];
                final mealId = mealPlan[DatabaseHelper.mealPlannerRecipeId];

                return FutureBuilder<String?>(
                  future: widget.dbHelper.getMealNameById(mealId),
                  builder: (context, mealNameSnapshot) {
                    if (mealNameSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const ListTile(
                        title: Text('Loading meal name...'),
                      );
                    } else if (mealNameSnapshot.hasError) {
                      return ListTile(
                        title: Text('Error: ${mealNameSnapshot.error}'),
                      );
                    } else {
                      final mealName = mealNameSnapshot.data ?? 'Unknown Meal';

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                              '${mealPlan[DatabaseHelper.mealPlannerMealType]}: $mealName'),
                          subtitle: Text(
                              'Time: ${mealPlan[DatabaseHelper.mealPlannerTime]}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  '${mealPlan[DatabaseHelper.mealPlannerDate]}'),
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    _showEditMealPlanDialog(mealPlan),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _showDeleteConfirmationDialog(
                                    mealPlan[DatabaseHelper.mealPlannerId]),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewMealPlan,
        child: const Icon(Icons.add),
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
