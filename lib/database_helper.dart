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
      FOREIGN KEY ($cardFolderId) REFERENCES $folderTable ($folderId)
    )
    ''');

    await _insertInitialFolders(db);
    await _insertInitialCards(db);
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

    cards.add({
      DatabaseHelper.cardName:
          "Ace of Hearts", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Hearts",
      DatabaseHelper.cardImageUrl: "assets/images/Hearts/htile000.png",
      DatabaseHelper.cardFolderId: folderIds["Breakfast"],
    });
    cards.add({
      DatabaseHelper.cardName: "2 of Hearts", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Hearts",
      DatabaseHelper.cardImageUrl: "assets/images/Hearts/htile001.png",
      DatabaseHelper.cardFolderId: folderIds["Breakfast"],
    });
    cards.add({
      DatabaseHelper.cardName: "3 of Hearts", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Hearts",
      DatabaseHelper.cardImageUrl: "assets/images/Hearts/htile002.png",
      DatabaseHelper.cardFolderId: folderIds["Lunch"],
    });
    // Spades
    cards.add({
      DatabaseHelper.cardName:
          "Ace of Spades", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Spades",
      DatabaseHelper.cardImageUrl: "assets/images/Spades/Stile000.png",
      DatabaseHelper.cardFolderId: folderIds["Lunch"],
    });
    cards.add({
      DatabaseHelper.cardName: "2 of Spades", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Spades",
      DatabaseHelper.cardImageUrl: "assets/images/Spades/Stile001.png",
      DatabaseHelper.cardFolderId: folderIds["Dinner"],
    });
    cards.add({
      DatabaseHelper.cardName: "3 of Spades", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Spades",
      DatabaseHelper.cardImageUrl: "assets/images/Spades/Stile002.png",
      DatabaseHelper.cardFolderId: folderIds["Dinner"],
    });

    for (var card in cards) {
      await db.insert(cardsTable, card);
    }
  }

  // Insert Card
  Future<int> insertCard(
      String name, String suit, String imageUrl, int folderId) async {
    Map<String, dynamic> row = {
      cardName: name,
      cardSuit: suit,
      cardImageUrl: imageUrl,
      cardFolderId: folderId,
    };
    return await _db.insert(cardsTable, row);
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

      // Debugging: Check the values before deleting
      print(
          "Moving card - ID: $cardId, Name: $cardName, Suit: $cardSuit, Image URL: $cardImageUrl");

      // Delete the original card
      await deleteCard(cardId);

      // Insert a new card into the new folder with the original values
      await insertCard(cardName, cardSuit, cardImageUrl, newFolderId);
    } else {
      print("Card not found");
    }
  }

  Future<void> addCardToFolder(String cardName, String cardImageUrl,
      int folderId, String cardSuit) async {
    final Map<String, dynamic> cardData = {
      DatabaseHelper.cardName: cardName,
      DatabaseHelper.cardImageUrl: cardImageUrl,
      DatabaseHelper.cardSuit: cardSuit,
      DatabaseHelper.cardFolderId: folderId,
    };

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
}
