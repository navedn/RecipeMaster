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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Card Name: ${card['name'] ?? 'Unknown'}', // Updated key
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Card Suit: ${card['suit'] ?? 'Unknown'}', // Updated key
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Image:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            // Use Image.asset with an error builder
            Image.asset(
              card['image_url'] ??
                  '', // Ensure there is a fallback if the key is not found
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.image, size: 50); // Fallback icon
              },
            ),
          ],
        ),
      ),
    );
  }
}
