import 'package:flutter/material.dart';
import 'database_helper.dart';

class RecipesScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final DatabaseHelper dbHelper;

  RecipesScreen({
    required this.categoryId,
    required this.categoryName,
    required this.dbHelper,
    Key? key,
  }) : super(key: key);

  @override
  _RecipesScreenState createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  late Future<List<Map<String, dynamic>>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _loadRecipes() {
    _recipesFuture = widget.dbHelper.getRecipesInCategory(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.categoryName} Recipes"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Recipes Found'));
          } else {
            var recipes = snapshot.data!;
            return ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                var recipe = recipes[index];
                return ListTile(
                  leading: recipe[DatabaseHelper.recipeImageUrl] != null
                      ? Image.network(
                          recipe[DatabaseHelper.recipeImageUrl],
                          width: 50,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.image, size: 50),
                  title: Text(recipe[DatabaseHelper.recipeName]),
                  onTap: () {
                    // Navigate to recipe details screen if needed
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
