import 'package:flutter/material.dart';
import 'database_helper.dart';

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

    int? selectedFolderId = card[DatabaseHelper.cardFolderId];

    Future<List<Map<String, dynamic>>> _foldersFuture =
        widget.dbHelper.getFolders();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Card"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "New Card Name"),
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Card"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Card Name"),
              ),
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(labelText: "Card Image URL"),
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
                String cardSuit =
                    widget.folderName; // Set cardSuit as folder name

                // Add the card to the folder
                await widget.dbHelper.addCardToFolder(
                  cardName,
                  cardImageUrl,
                  widget.folderID,
                  cardSuit,
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
          title: Text("Delete Card"),
          content: Text("Are you sure you want to delete this card?"),
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
                );
              },
            );
          }
        },
      ),
    );
  }
}
