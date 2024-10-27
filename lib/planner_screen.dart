import 'package:flutter/material.dart';
import 'database_helper.dart';

class PlannerScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const PlannerScreen({Key? key, required this.dbHelper}) : super(key: key);

  @override
  _PlannerScreenState createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  Future<List<Map<String, dynamic>>>? _mealPlans;

  @override
  void initState() {
    super.initState();
    _fetchMealPlans();
  }

  void _fetchMealPlans() {
    setState(() {
      _mealPlans = widget.dbHelper.getMealPlans();
    });
  }

  Future<void> _deleteMealPlan(int mealPlannerId) async {
    debugPrint('Deleting Meal Plan with ID: $mealPlannerId'); // Add debug print
    await widget.dbHelper.deleteMealPlan(mealPlannerId);
    _fetchMealPlans(); // Refresh the meal plans
  }

  void _showDeleteConfirmationDialog(int mealPlannerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Meal Plan"),
          content: Text("Are you sure you want to delete this meal plan?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                debugPrint('$mealPlannerId');
                await _deleteMealPlan(mealPlannerId);
                Navigator.of(context).pop(); // Close the dialog after deletion
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

                return FutureBuilder<String?>(
                  future: widget.dbHelper.getMealNameById(mealId),
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
                      final mealName = mealNameSnapshot.data ?? 'Unknown Meal';

                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                              '${mealPlan[DatabaseHelper.mealPlannerMealType]}: $mealName'),
                          subtitle: Text(
                              'Time: ${mealPlan[DatabaseHelper.mealPlannerTime]}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  '${mealPlan[DatabaseHelper.mealPlannerDate]}'),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _showDeleteConfirmationDialog(mealId),
                              ),
                            ],
                          ),
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
