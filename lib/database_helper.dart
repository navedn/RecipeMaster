import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "CardOrganizerDatabase.db";
  static const _databaseVersion = 1;

  // Folder table
  static const folderTable = 'folders';
  static const folderId = '_id';
  static const folderName = 'folder_name';
  static const folderTimestamp = 'timestamp';

  // Cards table
  static const cardsTable = 'cards';
  static const cardId = '_id';
  static const cardName = 'name';
  static const cardSuit = 'suit';
  static const cardImageUrl = 'image_url';
  static const cardFolderId = 'folder_id';
  static const cardIngredients = 'ingredients'; // Ingredients list
  static const cardServingSize = 'serving_size'; // Serving size
  static const cardInstructions = 'instructions'; // Recipe instructions
  static const cardPrepTime = 'prep_time'; // Preparation time in minutes
  static const cardCookTime = 'cook_time'; // Cooking time in minutes

  // GroceryList table
  static const groceryListTable = 'grocery_list';
  static const groceryItemId = '_id';
  static const groceryItemName = 'item_name';
  static const groceryItemChecked = 'checked';

  // MealPlanner table
  static const mealPlannerTable = 'meal_planner';
  static const mealPlannerId = '_id';
  static const mealPlannerDate = 'date';
  static const mealPlannerMealType = 'meal_type';
  static const mealPlannerRecipeId = 'recipe_id';
  static const mealPlannerNotes = 'notes';
  static const mealPlannerTime = 'time';

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
    CREATE TABLE $folderTable (
      $folderId INTEGER PRIMARY KEY,
      $folderName TEXT NOT NULL,
      $folderTimestamp TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE $cardsTable (
      $cardId INTEGER PRIMARY KEY,
      $cardName TEXT NOT NULL,
      $cardSuit TEXT NOT NULL,
      $cardImageUrl TEXT NOT NULL,
      $cardFolderId INTEGER,
      $cardIngredients TEXT,  -- New column for ingredients
      $cardServingSize INTEGER,   -- New column for serving size
      $cardInstructions TEXT,   -- New column for recipe instructions
      $cardPrepTime INTEGER,    -- New column for preparation time
      $cardCookTime INTEGER,    -- New column for cooking time    
      FOREIGN KEY ($cardFolderId) REFERENCES $folderTable ($folderId)
    )
    ''');

    // GroceryList table
    await db.execute('''
    CREATE TABLE $groceryListTable (
      $groceryItemId INTEGER PRIMARY KEY,
      $groceryItemName TEXT NOT NULL,
      $groceryItemChecked INTEGER NOT NULL DEFAULT 0
    )
  ''');

    // Create the meal planner table
    await db.execute('''
    CREATE TABLE $mealPlannerTable (
      $mealPlannerId INTEGER PRIMARY KEY,
      $mealPlannerDate TEXT NOT NULL,
      $mealPlannerMealType TEXT NOT NULL,
      $mealPlannerRecipeId INTEGER,
      $mealPlannerNotes TEXT,
      $mealPlannerTime TEXT,
      FOREIGN KEY ($mealPlannerRecipeId) REFERENCES $cardsTable ($cardId)
    )
  ''');

    await _insertInitialFolders(db);
    await _insertInitialCards(db);
    await _insertInitialMealPlans(db);
  }

  Future<void> _insertInitialFolders(Database db) async {
    List<String> folderNames = ['Breakfast', 'Lunch', 'Dinner'];
    String timestamp = DateTime.now().toIso8601String();

    for (String name in folderNames) {
      await db.insert(folderTable, {
        folderName: name,
        folderTimestamp: timestamp,
      });
    }
  }

  Future<void> _insertInitialCards(Database db) async {
    List<Map<String, dynamic>> cards = [];

    List<String> suits = ['Breakfast', 'Lunch', 'Dinner'];
    Map<String, int> folderIds = {
      'Breakfast': 1,
      'Lunch': 2,
      'Dinner': 3,
    };

    // Breakfast Recipes
    cards.add({
      DatabaseHelper.cardName: "Oatmeal", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Breakfast",
      DatabaseHelper.cardImageUrl: "assets/images/oatmeal.jpg",
      DatabaseHelper.cardFolderId: folderIds["Breakfast"],
      DatabaseHelper.cardIngredients:
          "1/2 cup old fashioned rolled oats, 1 cup milk, pinch of sea salt, 1/4 cup ground cinnamon, 1/4 teaspoon vanilla extract",
      DatabaseHelper.cardServingSize: 2,
      DatabaseHelper.cardInstructions:
          "1. Add oats, water or milk, salt, cinnamon and vanilla (if using) to a pot or saucepan over medium/high heat.\n"
              "2. Bring mixture to a low boil, reduce heat to a low simmer and continue to cook for about 5-7 minutes; stirring occasionally. Oatmeal is ready when the oats have soaked up most of the liquid and are creamy.\n"
              "3. Transfer to a bowl and add toppings of choice.",
      DatabaseHelper.cardPrepTime: 5,
      DatabaseHelper.cardCookTime: 10,
    });

// Breakfast Recipes
    cards.add({
      DatabaseHelper.cardName: "Pancakes", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Breakfast",
      DatabaseHelper.cardImageUrl: "assets/images/pancakes.jpg",
      DatabaseHelper.cardFolderId: folderIds["Breakfast"],
      DatabaseHelper.cardIngredients:
          "1 ½ cups all-purpose flour, 3 ½ teaspoons baking powder, 11 tablespoon white sugar, ¼ teaspoon salt, 1 ¼ cups milk, 1 egg, 3 tablespoons melted butter",
      DatabaseHelper.cardServingSize: 8,
      DatabaseHelper.cardInstructions:
          "1. Sift flour, baking powder, sugar, and salt together in a large bowl. Make a well in the center and add milk, melted butter, and egg; mix until smooth.\n"
              "2. Heat a lightly oiled griddle or pan over medium-high heat. \n"
              "3. Pour or scoop the batter onto the griddle, using approximately 1/4 cup for each pancake; cook until bubbles form and the edges are dry, about 2 to 3 minutes.\n"
              "4. Flip and cook until browned on the other side. Repeat with remaining batter.\n",
      DatabaseHelper.cardPrepTime: 5,
      DatabaseHelper.cardCookTime: 15,
    });

// Lunch Recipes
    cards.add({
      DatabaseHelper.cardName:
          "Chicken Salad", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Lunch",
      DatabaseHelper.cardImageUrl: "assets/images/chickensalad.jpg",
      DatabaseHelper.cardFolderId: folderIds["Lunch"],
      DatabaseHelper.cardIngredients:
          "12 ounces cooked chicken breast (finely chopped), 1/3 cup light mayonnaise, 1/2 cup celery (chopped), 1/3 cup red onion (diced), 2 tablespoons chicken broth, 1 teaspoon Dijon, 1/2 teaspoon seasoned salt, 1/2 teaspoon pepper",
      DatabaseHelper.cardServingSize: 6,
      DatabaseHelper.cardInstructions:
          "1. Combine all ingredients in a medium bowl and mix well. \n"
              "2. Mix well and season with salt and pepper.",
      DatabaseHelper.cardPrepTime: 15,
      DatabaseHelper.cardCookTime: 0, // No cooking required
    });

// Lunch Recipes
    cards.add({
      DatabaseHelper.cardName:
          "Egg Salad Sandwich", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Lunch",
      DatabaseHelper.cardImageUrl: "assets/images/eggsalad.jpg",
      DatabaseHelper.cardFolderId: folderIds["Lunch"],
      DatabaseHelper.cardIngredients:
          "4 hard-boiled eggs, 1/4 cup mayonnaise, 1 teaspoon mustard, 1 tablespoon chopped fresh dill, salt, pepper, 4 slices of bread, lettuce leaves",
      DatabaseHelper.cardServingSize: 4,
      DatabaseHelper.cardInstructions:
          "1. In a bowl, combine chopped eggs, mayonnaise, mustard, and dill. Mix until well combined.\n"
              "2. Season with salt and pepper to taste.\n"
              "3. Spread the egg salad onto slices of bread and add lettuce leaves. Top with another slice of bread and cut in half.",
      DatabaseHelper.cardPrepTime: 10,
      DatabaseHelper.cardCookTime: 0, // No cooking required
    });

// Dinner Recipes
    cards.add({
      DatabaseHelper.cardName:
          "Chicken Parmesan", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Dinner",
      DatabaseHelper.cardImageUrl: "assets/images/chicken_parmesan.jpg",
      DatabaseHelper.cardFolderId: folderIds["Dinner"],
      DatabaseHelper.cardIngredients:
          "2 boneless skinless chicken breasts, 1 cup breadcrumbs, 1/2 cup grated Parmesan cheese, 1 egg, 1 cup marinara sauce, 1 cup shredded mozzarella cheese, salt, peper, fresh basil",
      DatabaseHelper.cardServingSize: 2,
      DatabaseHelper.cardInstructions: "1. Preheat the oven to 375°F (190°C).\n"
          "2. Flatten chicken breasts to an even thickness.\n"
          "3. In a bowl, beat the egg. In another bowl, mix breadcrumbs and Parmesan cheese.\n"
          "4. Dip chicken in egg, then coat with breadcrumb mixture.\n"
          "5. Place chicken in a baking dish, cover with marinara sauce and mozzarella cheese.\n"
          "6. Bake for 25-30 minutes until chicken is cooked through and cheese is bubbly. Garnish with fresh basil before serving.",
      DatabaseHelper.cardPrepTime: 15,
      DatabaseHelper.cardCookTime: 30,
    });

// Dinner Recipes
    cards.add({
      DatabaseHelper.cardName: "Meatloaf", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Dinner",
      DatabaseHelper.cardImageUrl: "assets/images/meatloaf.jpg",
      DatabaseHelper.cardFolderId: folderIds["Dinner"],
      DatabaseHelper.cardIngredients:
          "1 pound ground beef, 1/2 cup breadcrumbs, 1/2 cup milk, 1/2 onion (chopped), 1 egg, 1 teaspoon salt, 1/2 teaspoon pepper, 1/4 cup ketchup, 1 tablespoon Worcestershire sauce",
      DatabaseHelper.cardServingSize: 4,
      DatabaseHelper.cardInstructions: "1. Preheat the oven to 350°F (175°C).\n"
          "2. In a bowl, combine ground beef, breadcrumbs, milk, onion, egg, salt, pepper, and Worcestershire sauce. Mix well.\n"
          "3. Shape the mixture into a loaf and place in a greased baking dish.\n"
          "4. Spread ketchup on top of the meatloaf.\n"
          "5. Bake for 1 hour or until the internal temperature reaches 160°F (70°C). Let rest before slicing.",
      DatabaseHelper.cardPrepTime: 15,
      DatabaseHelper.cardCookTime: 60,
    });

    for (var card in cards) {
      await db.insert(cardsTable, card);
    }
  }

  Future<void> _insertInitialMealPlans(Database db) async {
    List<Map<String, dynamic>> mealPlans = [
      {
        mealPlannerId: 1,
        mealPlannerDate: '2024-10-28',
        mealPlannerMealType: 'Breakfast',
        mealPlannerRecipeId: 1, // Assuming the Oatmeal recipe has id 1
        mealPlannerNotes: 'Start the day healthy!',
        mealPlannerTime: '08:00 AM',
      },
      {
        mealPlannerId: 2,
        mealPlannerDate: '2024-10-28',
        mealPlannerMealType: 'Lunch',
        mealPlannerRecipeId: 1, // Should also be oatmeal
        mealPlannerNotes: 'Light and nutritious.',
        mealPlannerTime: '12:30 PM',
      },
      {
        mealPlannerId: 3,
        mealPlannerDate: '2024-10-28',
        mealPlannerMealType: 'Dinner',
        mealPlannerRecipeId: 5, // Assuming Chicken Parmesan recipe has id 5
        mealPlannerNotes: 'A classic favorite!',
        mealPlannerTime: '06:30 PM',
      },
    ];

    for (var mealPlan in mealPlans) {
      await db.insert(mealPlannerTable, mealPlan);
    }
  }

  Future<void> insertCard(
      String name,
      String suit,
      String imageUrl,
      int folderId,
      String ingredients,
      int? servingSize,
      String instructions,
      int? prepTime,
      int? cookTime) async {
    final cardData = {
      DatabaseHelper.cardName: name,
      DatabaseHelper.cardSuit: suit,
      DatabaseHelper.cardImageUrl: imageUrl,
      DatabaseHelper.cardFolderId: folderId,
      DatabaseHelper.cardIngredients: ingredients,
      DatabaseHelper.cardServingSize: servingSize,
      DatabaseHelper.cardInstructions: instructions,
      DatabaseHelper.cardPrepTime: prepTime,
      DatabaseHelper.cardCookTime: cookTime,
    };

    await _db.insert(cardsTable, cardData);
  }

  // Fetch cards in a folder
  Future<List<Map<String, dynamic>>> getCardsInFolder(int folderId) async {
    return await _db.query(
      cardsTable,
      where: '$cardFolderId = ?',
      whereArgs: [folderId],
    );
  }

  // Update card name and folder
  Future<int> updateCard(int cardId, String newName, int newFolderId) async {
    Map<String, dynamic> row = {
      cardName: newName,
      cardFolderId: newFolderId,
    };
    return await _db.update(
      cardsTable,
      row,
      where: '$cardId = ?',
      whereArgs: [cardId],
    );
  }

  Future<void> updateCardDetails(int cardId, int servingSize, int prepTime,
      int cookTime, String ingredients, String instructions) async {
    await _db.update(
      cardsTable,
      {
        DatabaseHelper.cardPrepTime: prepTime,
        DatabaseHelper.cardCookTime: cookTime,
        DatabaseHelper.cardServingSize: servingSize,
        DatabaseHelper.cardIngredients: ingredients,
        DatabaseHelper.cardInstructions: instructions,
      },
      where: '${DatabaseHelper.cardId} = ?',
      whereArgs: [cardId],
    );
  }

  Future<int> renameCard(int id, String newName) async {
    Map<String, dynamic> updates = {
      cardName: newName,
    };
    return await _db.update(
      cardsTable,
      updates,
      where: '$cardId = ?',
      whereArgs: [id],
    );
  }

  // Delete a card
  Future<int> deleteCard(int id) async {
    return await _db.delete(
      cardsTable,
      where: '$cardId = ?',
      whereArgs: [id],
    );
  }

  // Fetch all folders
  Future<List<Map<String, dynamic>>> getFolders() async {
    return await _db.query(folderTable);
  }

  Future<int> insertFolder(String name) async {
    final timestamp = DateTime.now().toIso8601String();
    Map<String, dynamic> row = {
      folderName: name,
      folderTimestamp: timestamp,
    };
    return await _db.insert(folderTable, row);
  }

  // Update folder details
  Future<int> updateFolder(int id, String newName) async {
    Map<String, dynamic> row = {
      folderName: newName,
      folderTimestamp: DateTime.now().toIso8601String(),
    };
    return await _db.update(
      folderTable,
      row,
      where: '$folderId = ?',
      whereArgs: [id],
    );
  }

  // Delete folder (also deletes all cards in the folder)
  Future<int> deleteFolder(int id) async {
    // Delete all cards in the folder
    await _db.delete(
      cardsTable,
      where: '$cardFolderId = ?',
      whereArgs: [id],
    );

    // Delete the folder itself
    return await _db.delete(
      folderTable,
      where: '$folderId = ?',
      whereArgs: [id],
    );
  }

  Future<int> moveToFolder(int cardId, int newFolderId) async {
    print("Moving card ID $cardId to folder ID $newFolderId");
    Map<String, dynamic> updates = {
      cardFolderId:
          newFolderId, // Assuming cardFolderId is the column for folder IDs
    };
    return await _db.update(
      cardsTable,
      updates,
      where: '$cardId = ?',
      whereArgs: [cardId],
    );
  }

  Future<void> moveCardToDifferentFolder(int cardId, int newFolderId) async {
    // Fetch the original card data using the correct column name
    final originalCard = await _db.query(
      cardsTable,
      where:
          '${DatabaseHelper.cardId} = ?', // Ensure you are using the column name here
      whereArgs: [cardId],
    );

    if (originalCard.isNotEmpty) {
      // Get original card data with proper type casting
      final originalCardData = originalCard.first;
      String cardName =
          (originalCardData[DatabaseHelper.cardName] as String?) ?? '';
      String cardSuit =
          (originalCardData[DatabaseHelper.cardSuit] as String?) ?? '';
      String cardImageUrl =
          (originalCardData[DatabaseHelper.cardImageUrl] as String?) ?? '';
      String cardIngredients =
          (originalCardData[DatabaseHelper.cardIngredients] as String?) ?? '';
      int? cardServingSize =
          (originalCardData[DatabaseHelper.cardServingSize] as int?);
      String cardInstructions =
          (originalCardData[DatabaseHelper.cardInstructions] as String?) ?? '';
      int? cardPrepTime =
          (originalCardData[DatabaseHelper.cardPrepTime] as int?);
      int? cardCookTime =
          (originalCardData[DatabaseHelper.cardCookTime] as int?);

      // Debugging: Check the values before deleting
      print(
          "Moving card - ID: $cardId, Name: $cardName, Suit: $cardSuit, Image URL: $cardImageUrl, Ingredients: $cardIngredients, Serving Size: $cardServingSize, Instructions: $cardInstructions, Prep Time: $cardPrepTime, Cook Time: $cardCookTime");

      // Delete the original card
      await deleteCard(cardId);

      // Insert a new card into the new folder with the original values
      await insertCard(
        cardName,
        cardSuit,
        cardImageUrl,
        newFolderId,
        cardIngredients,
        cardServingSize,
        cardInstructions,
        cardPrepTime,
        cardCookTime,
      );
    } else {
      print("Card not found");
    }
  }

  Future<void> addCardToFolder(
    String cardName,
    String cardImageUrl,
    int folderId,
    String cardSuit,
    int servingSize,
    int prepTime,
    int cookTime,
    String ingredients,
    String instructions,
  ) async {
    // Create a map for the card data with new attributes
    final Map<String, dynamic> cardData = {
      DatabaseHelper.cardName: cardName,
      DatabaseHelper.cardImageUrl: cardImageUrl,
      DatabaseHelper.cardSuit: cardSuit,
      DatabaseHelper.cardFolderId: folderId,
      DatabaseHelper.cardServingSize: servingSize,
      DatabaseHelper.cardPrepTime: prepTime, // New attribute
      DatabaseHelper.cardCookTime: cookTime, // New attribute
      DatabaseHelper.cardIngredients: ingredients, // New attribute
      DatabaseHelper.cardInstructions: instructions, // New attribute
    };

    // Insert the card data into the cardsTable
    await _db.insert(cardsTable, cardData);
  }

  // Method to get the count of cards in a folder
  Future<int> getCardCountInFolder(int folderId) async {
    var result = await _db.rawQuery(
        'SELECT COUNT(*) FROM $cardsTable WHERE $cardFolderId = ?', [folderId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

// Method to get the first card image URL in a folder
  Future<String?> getFirstCardImageInFolder(int folderId) async {
    var result = await _db.rawQuery(
        'SELECT $cardImageUrl FROM $cardsTable WHERE $cardFolderId = ? LIMIT 1',
        [folderId]);
    return result.isNotEmpty ? result.first[cardImageUrl] as String? : null;
  }

  Future<int> insertGroceryItem(String itemName) async {
    Map<String, dynamic> row = {
      groceryItemName: itemName,
      groceryItemChecked: 0, // Initially unchecked
    };
    return await _db.insert(groceryListTable, row);
  }

// Update grocery item name
  Future<int> updateGroceryItem(int id, String newName) async {
    Map<String, dynamic> updates = {
      groceryItemName: newName,
    };
    return await _db.update(
      groceryListTable,
      updates,
      where: '$groceryItemId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteGroceryItem(int id) async {
    return await _db.delete(
      groceryListTable,
      where: '$groceryItemId = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getGroceryListItems() async {
    final db = await _db;
    return await db.query(
      groceryListTable,
    );
  }

  Future<void> updateGroceryItemChecked(int itemId, bool isChecked) async {
    final db = await _db;
    await db.update(
      groceryListTable,
      {groceryItemChecked: isChecked ? 1 : 0},
      where: '$groceryItemId = ?',
      whereArgs: [itemId],
    );
  }

  Future<int> insertMealPlan({
    required String date,
    required String mealType,
    required int? recipeId, // Make this required if you always want it
    String? notes,
    String? time,
  }) async {
    // Create a map representing the new row to be inserted
    Map<String, dynamic> row = {
      mealPlannerDate: date,
      mealPlannerMealType: mealType,
      mealPlannerRecipeId: recipeId, // Recipe ID should be set here
      mealPlannerNotes: notes,
      mealPlannerTime: time,
    };

    // Check if recipeId is valid
    if (recipeId == null) {
      debugPrint("Error: recipeId cannot be null.");
      throw ArgumentError("recipeId cannot be null.");
    }

    // Insert the row into the database and return the new record ID
    int id = await _db.insert(mealPlannerTable, row);

    // Debug log for confirmation
    debugPrint("Inserted meal plan with ID: $id and Recipe ID: $recipeId");

    return recipeId; // Return the newly inserted meal plan ID
  }

// Method to fetch meal plans for a specific date
  Future<List<Map<String, dynamic>>> getMealPlansByDate(String date) async {
    return await _db.query(
      mealPlannerTable,
      where: '$mealPlannerDate = ?',
      whereArgs: [date],
    );
  }

  Future<List<Map<String, dynamic>>> getMealPlans() async {
    return await _db.rawQuery('''
    SELECT * FROM $mealPlannerTable 
    ORDER BY 
      $mealPlannerDate ASC, 
      CASE
        WHEN $mealPlannerTime LIKE '%AM' THEN 
          strftime('%H:%M', 
            CASE 
              WHEN SUBSTR($mealPlannerTime, 1, 2) = '12' THEN '00:' || SUBSTR($mealPlannerTime, 4, 2) 
              ELSE $mealPlannerTime
            END)
        WHEN $mealPlannerTime LIKE '%PM' THEN 
          strftime('%H:%M', 
            CASE 
              WHEN SUBSTR($mealPlannerTime, 1, 2) = '12' THEN $mealPlannerTime
              ELSE CAST(SUBSTR($mealPlannerTime, 1, 2) AS INTEGER) + 12 || ':' || SUBSTR($mealPlannerTime, 4, 2)
            END)
        ELSE 
          $mealPlannerTime
      END ASC
  ''');
  }

  Future<String?> getMealNameById(int recipeId) async {
    final List<Map<String, dynamic>> results = await _db.query(
      cardsTable,
      columns: [cardName],
      where: '$cardId = ?',
      whereArgs: [recipeId],
    );

    // Check if any results were returned
    if (results.isNotEmpty) {
      return results.first[cardName] as String; // Return the meal name
    }

    return null; // Return null if no meal was found with the given ID
  }

  // Method to delete a meal plan by ID
  Future<int> deleteMealPlan(int id) async {
    return await _db.delete(
      mealPlannerTable,
      where: '$mealPlannerId = ?',
      whereArgs: [id],
    );
  }

  // Method to update a meal plan by ID
  Future<int> updateMealPlan(
    int id, {
    String? date,
    String? mealType,
    int? recipeId,
    String? notes,
    String? time,
  }) async {
    Map<String, dynamic> updatedFields = {};

    // Only add fields to be updated if they are not null
    if (date != null) updatedFields[mealPlannerDate] = date;
    if (mealType != null) updatedFields[mealPlannerMealType] = mealType;
    if (recipeId != null) updatedFields[mealPlannerRecipeId] = recipeId;
    if (notes != null) updatedFields[mealPlannerNotes] = notes;
    if (time != null) updatedFields[mealPlannerTime] = time;

    return await _db.update(
      mealPlannerTable,
      updatedFields,
      where: '$mealPlannerId = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateMealPlanRecipeId(int mealPlanId, int newRecipeId) async {
    return await _db.update(
      mealPlannerTable,
      {mealPlannerRecipeId: newRecipeId},
      where: '$mealPlannerId = ?',
      whereArgs: [mealPlanId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllRecipeIds() async {
    return await _db.query(
      cardsTable,
      columns: [cardId], // Only retrieve the ID
    );
  }

  Future<void> _clearAllData() async {
    // Delete all entries from the specified tables
    await _db.delete(folderTable);
    await _db.delete(cardsTable);
    await _db.delete(groceryListTable);
    await _db.delete(mealPlannerTable);
  }

  Future<void> clearAllData() async {
    // Clear all user-entered data in folders, cards, grocery list, and meal planner tables
    await _clearAllData();
  }

  Future<void> restoreDefaults() async {
    // Clear all data in folders, cards, grocery list, and meal planner tables
    await _clearAllData();

    // Reinsert the initial data
    await _insertInitialFolders(_db);
    await _insertInitialCards(_db);
    await _insertInitialMealPlans(_db);
  }
}
