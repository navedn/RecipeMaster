import 'package:flutter/material.dart';
import 'database_helper.dart';

class PlannerScreen extends StatefulWidget {
  final DatabaseHelper dbHelper; // Add a variable to hold the DatabaseHelper

  // Constructor to accept DatabaseHelper
  const PlannerScreen({Key? key, required this.dbHelper}) : super(key: key);

  @override
  _PlannerScreenState createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  Future<List<Map<String, dynamic>>>? _mealPlans;

  @override
  void initState() {
    super.initState();
    _fetchMealPlans(); // Fetch meal plans directly using the passed dbHelper
  }

  void _fetchMealPlans() {
    setState(() {
      _mealPlans =
          widget.dbHelper.getMealPlans(); // Use the instance from the widget
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Planner'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _mealPlans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No meal plans available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final mealPlan = snapshot.data![index];
                final mealId = mealPlan[DatabaseHelper.mealPlannerId];

                // Using FutureBuilder to fetch meal name
                return FutureBuilder<String?>(
                  future: widget.dbHelper
                      .getMealNameById(mealId), // Call getMealNameById
                  builder: (context, mealNameSnapshot) {
                    if (mealNameSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ListTile(
                        title: Text('Loading meal name...'),
                      );
                    } else if (mealNameSnapshot.hasError) {
                      return ListTile(
                        title: Text('Error: ${mealNameSnapshot.error}'),
                      );
                    } else {
                      final mealName = mealNameSnapshot.data ??
                          'Unknown Meal'; // Handle null

                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                              '${mealPlan[DatabaseHelper.mealPlannerMealType]}: $mealName'),
                          subtitle: Text(
                              'Time: ${mealPlan[DatabaseHelper.mealPlannerTime]}'),
                          trailing: Text(
                              '${mealPlan[DatabaseHelper.mealPlannerDate]}'),
                        ),
                      );
                    }
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
