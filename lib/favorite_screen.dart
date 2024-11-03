import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'RecipeInformationScreen.dart';

class FavoriteCardsScreen extends StatefulWidget {
  final int folderID;
  final String folderName;
  final DatabaseHelper dbHelper;

  const FavoriteCardsScreen({
    required this.folderID,
    required this.folderName,
    required this.dbHelper,
    super.key,
  });

  @override
  _FavoriteCardsScreenState createState() => _FavoriteCardsScreenState();
}

class _FavoriteCardsScreenState extends State<FavoriteCardsScreen> {
  late Future<List<Map<String, dynamic>>> _favoriteCardsFuture;

  @override
  void initState() {
    super.initState();
    _loadFavoriteCards();
  }

  void _loadFavoriteCards() {
    _favoriteCardsFuture = widget.dbHelper.getFavoriteCards(widget.folderID);
  }

  void _refreshUI() {
    setState(() {
      _loadFavoriteCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Favorite Recipes"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _favoriteCardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Favorite Recipes Found'));
          } else {
            var favoriteCards = snapshot.data!;
            return ListView.builder(
              itemCount: favoriteCards.length,
              itemBuilder: (context, index) {
                var card = favoriteCards[index];
                return ListTile(
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: card[DatabaseHelper.cardImageUrl] != null &&
                            card[DatabaseHelper.cardImageUrl].isNotEmpty
                        ? Image.asset(
                            card[DatabaseHelper.cardImageUrl],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image, size: 40);
                            },
                          )
                        : const Icon(Icons.image, size: 40),
                  ),
                  title: Text(card[DatabaseHelper.cardName]),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RecipeInformationScreen(
                          card: card,
                          dbHelper: widget.dbHelper,
                        ),
                      ),
                    );
                    _refreshUI(); // Refresh UI after returning from RecipeInformationScreen
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
