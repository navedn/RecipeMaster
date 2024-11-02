import 'package:flutter/material.dart';
import 'database_helper.dart';

class RecipeInformationScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  final Map<String, dynamic> card;

  const RecipeInformationScreen(
      {super.key, required this.card, required this.dbHelper});

  @override
  State<RecipeInformationScreen> createState() =>
      _RecipeInformationScreenState();
}

class _RecipeInformationScreenState extends State<RecipeInformationScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus(); // Load initial favorite status
  }

  Future<void> _loadFavoriteStatus() async {
    // Load initial favorite status from the database
    isFavorite = widget.card['is_fav'] == 1;
    setState(() {});
  }

  Future<void> _updateFavoriteStatus() async {
    setState(() {
      isFavorite = !isFavorite; // Toggle the favorite status
    });

    // Update the favorite status in the database
    await widget.dbHelper.updateCardIsFavorite(
      widget.card['_id'],
      isFavorite,
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Card data: ${widget.card}'); // Debug line
    debugPrint('Card data 2: ${widget.card['_id']}');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card['name'] ?? 'Card Details'), // Updated key
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _updateFavoriteStatus, // Call update method on press
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            SizedBox(
              width: double.infinity,
              height: 250,
              child: Image.asset(
                widget.card['image_url'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image, size: 50); // Fallback icon
                },
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Recipe Serving Size: ${widget.card['serving_size'] ?? 'Unknown'} servings', // Updated key
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Recipe Prep Time: ${widget.card['prep_time'] ?? 'Unknown'} minutes', // Updated key
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Recipe Cook Time: ${widget.card['cook_time'] ?? 'Unknown'} minutes', // Updated key
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),

            const Text(
              'Ingredients:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // List of Ingredients
            _buildIngredientsList(widget.card['ingredients']),

            const SizedBox(height: 16),

            const Text(
              'Instructions:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Text(
              widget.card['instructions'] ?? 'Unknown', // Updated key
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Function to build the list of ingredients
  Widget _buildIngredientsList(String ingredients) {
    // Split the ingredients string by commas to create a list
    List<String> ingredientList =
        ingredients.split(',').map((ingredient) => ingredient.trim()).toList();

    return ListView.builder(
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling for inner ListView
      shrinkWrap: true, // Allow the ListView to take only the needed height
      itemCount: ingredientList.length,
      itemBuilder: (context, index) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '- ${ingredientList[index]}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.green),
              onPressed: () async {
                await widget.dbHelper.insertGroceryItem(ingredientList[index]);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('${ingredientList[index]} added to Shopping List'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
