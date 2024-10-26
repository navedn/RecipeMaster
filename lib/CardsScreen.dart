import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'RecipeInformationScreen.dart';

class CardsScreen extends StatefulWidget {
  final int folderID;
  final String folderName;
  final DatabaseHelper dbHelper;

  CardsScreen({
    required this.folderID,
    required this.folderName,
    required this.dbHelper,
    Key? key,
  }) : super(key: key);

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  late Future<List<Map<String, dynamic>>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() {
    _cardsFuture = widget.dbHelper.getCardsInFolder(widget.folderID);
  }

  void _refreshUI() {
    setState(() {
      _loadCards();
    });
  }

  void _showRenameDialog(Map<String, dynamic> card) {
    TextEditingController nameController =
        TextEditingController(text: card[DatabaseHelper.cardName]);

    TextEditingController prepTimeController = TextEditingController(
        text: card[DatabaseHelper.cardPrepTime]?.toString() ?? '');

    TextEditingController cookTimeController = TextEditingController(
        text: card[DatabaseHelper.cardCookTime]?.toString() ?? '');

    TextEditingController servingSizeController = TextEditingController(
        text: card[DatabaseHelper.cardServingSize]?.toString() ?? '');

    TextEditingController ingredientsController =
        TextEditingController(text: card[DatabaseHelper.cardIngredients]);

    TextEditingController instructionsController =
        TextEditingController(text: card[DatabaseHelper.cardInstructions]);

    int? selectedFolderId = card[DatabaseHelper.cardFolderId];

    Future<List<Map<String, dynamic>>> _foldersFuture =
        widget.dbHelper.getFolders();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Recipe"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "New Recipe Name"),
                  ),
                  TextField(
                    controller: servingSizeController,
                    decoration: InputDecoration(labelText: "Serving Size"),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: prepTimeController,
                    decoration:
                        InputDecoration(labelText: "Preparation Time (min)"),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: cookTimeController,
                    decoration:
                        InputDecoration(labelText: "Cooking Time (min)"),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: ingredientsController,
                    decoration: InputDecoration(labelText: "Ingredients"),
                    maxLines:
                        3, // Increase the number of lines for a taller input
                    keyboardType: TextInputType.multiline,
                  ),
                  TextField(
                    controller: instructionsController,
                    decoration: InputDecoration(labelText: "Instructions"),
                    maxLines:
                        5, // Increase the number of lines for a taller input
                    keyboardType: TextInputType.multiline,
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _foldersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No Folders Found');
                      } else {
                        var folders = snapshot.data!;
                        return DropdownButton<int>(
                          value: selectedFolderId,
                          onChanged: (int? newValue) {
                            setState(() {
                              selectedFolderId = newValue;
                            });
                          },
                          items: folders.map<DropdownMenuItem<int>>((folder) {
                            return DropdownMenuItem<int>(
                              value: folder[DatabaseHelper.folderId],
                              child: Text(folder[DatabaseHelper.folderName]),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await widget.dbHelper.renameCard(
                  card[DatabaseHelper.cardId],
                  nameController.text,
                );
                await widget.dbHelper.updateCardDetails(
                  card[DatabaseHelper.cardId],
                  int.tryParse(servingSizeController.text) ?? 0,
                  int.tryParse(prepTimeController.text) ?? 0,
                  int.tryParse(cookTimeController.text) ?? 0,
                  ingredientsController.text,
                  instructionsController.text,
                );
                if (selectedFolderId != card[DatabaseHelper.cardFolderId]) {
                  await widget.dbHelper.moveCardToDifferentFolder(
                    card[DatabaseHelper.cardId],
                    selectedFolderId!,
                  );
                }
                _refreshUI();
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showAddCardDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController imageUrlController = TextEditingController();

    // New functionality
    TextEditingController prepTimeController = TextEditingController();
    TextEditingController cookTimeController = TextEditingController();
    TextEditingController ingredientsController = TextEditingController();
    TextEditingController instructionsController = TextEditingController();
    TextEditingController servingSizeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Recipe"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Recipe Name"),
              ),
              TextField(
                controller: servingSizeController,
                decoration: InputDecoration(labelText: "Serving Size"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: prepTimeController,
                decoration:
                    InputDecoration(labelText: "Preparation Time (min)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: cookTimeController,
                decoration: InputDecoration(labelText: "Cooking Time (min)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: ingredientsController,
                decoration: InputDecoration(labelText: "Ingredients"),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              TextField(
                controller: instructionsController,
                decoration: InputDecoration(labelText: "Instructions"),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(labelText: "Recipe Image Path"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String cardName = nameController.text;
                String cardImageUrl = imageUrlController.text;
                int prepTime = int.tryParse(prepTimeController.text) ?? 0;
                int cookTime = int.tryParse(cookTimeController.text) ?? 0;
                int servingSize = int.tryParse(servingSizeController.text) ?? 0;

                String ingredients = ingredientsController.text;
                String instructions = instructionsController.text;

                // Add the card to the folder with all details
                await widget.dbHelper.addCardToFolder(
                  cardName,
                  cardImageUrl,
                  widget.folderID,
                  widget.folderName, // Set cardSuit as folder name
                  servingSize,
                  prepTime,
                  cookTime,
                  ingredients,
                  instructions,
                );

                _refreshUI(); // Refresh the UI after adding the card
                Navigator.of(context).pop();
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> card) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Recipe"),
          content: Text("Are you sure you want to delete this recipe?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await widget.dbHelper.deleteCard(card[DatabaseHelper.cardId]);
                _refreshUI(); // Refresh the UI after deletion
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipes for ${widget.folderName}"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddCardDialog(),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Cards Found'));
          } else {
            var cards = snapshot.data!;
            return ListView.builder(
              itemCount: cards.length,
              itemBuilder: (context, index) {
                var card = cards[index];
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 200,
                    child: card[DatabaseHelper.cardImageUrl] != null &&
                            card[DatabaseHelper.cardImageUrl].isNotEmpty
                        ? Image.asset(
                            card[DatabaseHelper.cardImageUrl],
                            fit: BoxFit
                                .cover, // This will cover the whole container without distorting
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.image,
                                  size: 50); // Fallback icon
                            },
                          )
                        : Icon(Icons.image, size: 50), // Fallback icon
                  ),
// Fallback icon
                  title: Text(card[DatabaseHelper.cardName]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showRenameDialog(card),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _showDeleteConfirmationDialog(card),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RecipeInformationScreen(
                            card: card, dbHelper: widget.dbHelper),
                      ),
                    );
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
