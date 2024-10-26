import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "RecipeBookDatabase.db";
  static const _databaseVersion = 1;

  // Category table
  static const categoryTable = 'categories';
  static const categoryId = '_id';
  static const categoryName = 'category_name';
  static const categoryTimestamp = 'timestamp';

  // Recipes table
  static const recipesTable = 'recipes';
  static const recipeId = '_id';
  static const recipeName = 'name';
  static const recipeIngredients = 'ingredients';
  static const recipeInstructions = 'instructions';
  static const recipeImageUrl = 'image_url';
  static const recipeCategoryId = 'category_id';

  late Database _db;

  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $categoryTable (
      $categoryId INTEGER PRIMARY KEY,
      $categoryName TEXT NOT NULL,
      $categoryTimestamp TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE $recipesTable (
      $recipeId INTEGER PRIMARY KEY,
      $recipeName TEXT NOT NULL,
      $recipeIngredients TEXT NOT NULL,
      $recipeInstructions TEXT NOT NULL,
      $recipeImageUrl TEXT,
      $recipeCategoryId INTEGER,
      FOREIGN KEY ($recipeCategoryId) REFERENCES $categoryTable ($categoryId)
    )
    ''');

    await _insertInitialCategories(db);
  }

  Future<void> _insertInitialCategories(Database db) async {
    List<String> initialCategories = ['Breakfast', 'Lunch', 'Dinner'];
    String timestamp = DateTime.now().toIso8601String();

    for (String name in initialCategories) {
      await db.insert(categoryTable, {
        categoryName: name,
        categoryTimestamp: timestamp,
      });
    }
  }

  // Insert a new recipe
  Future<int> insertRecipe(String name, String ingredients, String instructions,
      String imageUrl, int categoryId) async {
    Map<String, dynamic> row = {
      recipeName: name,
      recipeIngredients: ingredients,
      recipeInstructions: instructions,
      recipeImageUrl: imageUrl,
      recipeCategoryId: categoryId,
    };
    return await _db.insert(recipesTable, row);
  }

  // Fetch recipes in a category
  Future<List<Map<String, dynamic>>> getRecipesInCategory(
      int categoryId) async {
    return await _db.query(
      recipesTable,
      where: '$recipeCategoryId = ?',
      whereArgs: [categoryId],
    );
  }

  // Update a recipe
  Future<int> updateRecipe(int recipeId, String newName, String newIngredients,
      String newInstructions, String newImageUrl, int newCategoryId) async {
    Map<String, dynamic> row = {
      recipeName: newName,
      recipeIngredients: newIngredients,
      recipeInstructions: newInstructions,
      recipeImageUrl: newImageUrl,
      recipeCategoryId: newCategoryId,
    };
    return await _db.update(
      recipesTable,
      row,
      where: '$recipeId = ?',
      whereArgs: [recipeId],
    );
  }

  // Delete a recipe
  Future<int> deleteRecipe(int id) async {
    return await _db.delete(
      recipesTable,
      where: '$recipeId = ?',
      whereArgs: [id],
    );
  }

  // Fetch all categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    return await _db.query(categoryTable);
  }

  // Insert a new category
  Future<int> insertCategory(String name) async {
    final timestamp = DateTime.now().toIso8601String();
    Map<String, dynamic> row = {
      categoryName: name,
      categoryTimestamp: timestamp,
    };
    return await _db.insert(categoryTable, row);
  }

  // Update category details
  Future<int> updateCategory(int id, String newName) async {
    Map<String, dynamic> row = {
      categoryName: newName,
      categoryTimestamp: DateTime.now().toIso8601String(),
    };
    return await _db.update(
      categoryTable,
      row,
      where: '$categoryId = ?',
      whereArgs: [id],
    );
  }

  // Delete category (also deletes all recipes in the category)
  Future<int> deleteCategory(int id) async {
    // Delete all recipes in the category
    await _db.delete(
      recipesTable,
      where: '$recipeCategoryId = ?',
      whereArgs: [id],
    );

    // Delete the category itself
    return await _db.delete(
      categoryTable,
      where: '$categoryId = ?',
      whereArgs: [id],
    );
  }

  // Method to get the count of recipes in a category
  Future<int> getRecipeCountInCategory(int categoryId) async {
    var result = await _db.rawQuery(
        'SELECT COUNT(*) FROM $recipesTable WHERE $recipeCategoryId = ?',
        [categoryId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Method to get the first recipe image URL in a category
  Future<String?> getFirstRecipeImageInCategory(int categoryId) async {
    var result = await _db.rawQuery(
        'SELECT $recipeImageUrl FROM $recipesTable WHERE $recipeCategoryId = ? LIMIT 1',
        [categoryId]);
    return result.isNotEmpty ? result.first[recipeImageUrl] as String? : null;
  }
}
