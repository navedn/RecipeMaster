import 'package:flutter/material.dart';
import 'package:recipemaster/SettingsScreen.dart';
import 'database_helper.dart';
import 'CardsScreen.dart';
import 'shopping_list_screen.dart';
import 'planner_screen.dart';
import 'favorite_screen.dart';

class FoldersScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const FoldersScreen({required this.dbHelper, super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  Future<List<Map<String, dynamic>>>? _foldersFuture;
  int _selectedIndex = 0; // Variable to track the selected index

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  // Function to load all folders from the database
  void _loadFolders() {
    _foldersFuture = widget.dbHelper.getFolders();
  }

  // Function to add a new folder
  Future<void> _addFolder() async {
    TextEditingController folderNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Recipe Category'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(hintText: "Recipe Category Name"),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                if (folderNameController.text.isNotEmpty) {
                  await widget.dbHelper.insertFolder(folderNameController.text);
                  setState(() {
                    _loadFolders();
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to update a folder's name
  Future<void> _updateFolder(int folderId, String currentName) async {
    TextEditingController folderNameController =
        TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Recipe Category'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(hintText: "New Recipe Name"),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () async {
                if (folderNameController.text.isNotEmpty) {
                  await widget.dbHelper
                      .updateFolder(folderId, folderNameController.text);
                  setState(() {
                    _loadFolders();
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to delete a folder
  Future<void> _deleteFolder(int folderId) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Recipe Category'),
          content: const Text(
              'Are you sure you want to delete this recipe category?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await widget.dbHelper.deleteFolder(folderId);
                setState(() {
                  _loadFolders();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to handle bottom navigation bar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on the Folders screen; no navigation needed
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ShoppingListScreen(dbHelper: widget.dbHelper)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => PlannerScreen(dbHelper: widget.dbHelper)),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SettingsScreen(dbHelper: widget.dbHelper)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RecipeMaster'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_sharp),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FavoriteCardsScreen(
                          folderID: 1,
                          folderName: 'What',
                          dbHelper: widget.dbHelper,
                        )),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addFolder,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _foldersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Folders Found'));
          } else {
            var folders = snapshot.data!;
            return ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                var folder = folders[index];

                return FutureBuilder(
                  future: Future.wait([
                    widget.dbHelper
                        .getCardCountInFolder(folder[DatabaseHelper.folderId]),
                    widget.dbHelper.getFirstCardImageInFolder(
                        folder[DatabaseHelper.folderId]),
                  ]),
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: Text(folder[DatabaseHelper.folderName]),
                        subtitle: const Text('Loading recipe info...'),
                      );
                    } else if (snapshot.hasError) {
                      return ListTile(
                        title: Text(folder[DatabaseHelper.folderName]),
                        subtitle: const Text('Error loading recipe info'),
                      );
                    } else {
                      int cardCount = snapshot.data![0] as int;
                      String? firstCardImageUrl = snapshot.data![1] as String?;

                      return ListTile(
                        leading: SizedBox(
                          width: 40,
                          height: 200,
                          child: firstCardImageUrl != null
                              ? Image.asset(
                                  firstCardImageUrl,
                                  fit: BoxFit
                                      .cover, // This will cover the whole container without distorting
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image,
                                        size: 50); // Fallback icon
                                  },
                                )
                              : const Icon(Icons.image, size: 50),
                        ),
                        title: Text(folder[DatabaseHelper.folderName]),
                        subtitle: Text('$cardCount recipes'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _updateFolder(
                                folder[DatabaseHelper.folderId],
                                folder[DatabaseHelper.folderName],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteFolder(
                                folder[DatabaseHelper.folderId],
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CardsScreen(
                                folderID: folder[DatabaseHelper.folderId],
                                folderName: folder[DatabaseHelper.folderName],
                                dbHelper: widget.dbHelper,
                              ),
                            ),
                          );

                          setState(() {
                            _loadFolders(); // Refresh the folder list
                          });
                        },
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Shopping'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Planner'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
