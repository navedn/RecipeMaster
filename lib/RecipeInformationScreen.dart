import 'package:flutter/material.dart';

class RecipeInformationScreen extends StatelessWidget {
  final Map<String, dynamic> card;

  RecipeInformationScreen({required this.card});

  @override
  Widget build(BuildContext context) {
    debugPrint('Card data: $card'); // Debug line

    return Scaffold(
      appBar: AppBar(
        title: Text(card['name'] ?? 'Card Details'), // Updated key
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            Container(
              width: double.infinity,
              height: 250,
              child: Image.asset(
                card['image_url'] ??
                    '', // Ensure there is a fallback if the key is not found
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image, size: 50); // Fallback icon
                },
              ),
            ),
            SizedBox(height: 8),

            Text(
              'Recipe Serving Size: ${card['serving_size'] ?? 'Unknown'} servings', // Updated key
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Recipe Prep Time: ${card['prep_time'] ?? 'Unknown'} minutes', // Updated key
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Recipe Cook Time: ${card['cook_time'] ?? 'Unknown'} minutes', // Updated key
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),

            Text(
              'Ingredients:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // List of Ingredients
            _buildIngredientsList(card['ingredients']),

            SizedBox(height: 16),

            Text(
              'Instructions:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            Text(
              card['instructions'] ?? 'Unknown', // Updated key
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
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
          NeverScrollableScrollPhysics(), // Disable scrolling for inner ListView
      shrinkWrap: true, // Allow the ListView to take only the needed height
      itemCount: ingredientList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            '- ${ingredientList[index]}', // Format each ingredient
            style: TextStyle(fontSize: 18),
          ),
        );
      },
    );
  }
}
