import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for database
import 'package:lucide_icons/lucide_icons.dart';
import 'package:offline_attendence/pages/dashboard/bca/Defult.dart';
import 'package:offline_attendence/pages/dashboard/bca/eng.dart';
import 'package:offline_attendence/pages/dashboard/bca/math.dart';
import 'package:offline_attendence/pages/profile/profile_page.dart';
import 'package:offline_attendence/pages/log_in/login-page.dart'; // Lucide Icons for modern look
import 'bca/bca.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Class Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        hintColor: Colors.blueAccent, // BlueAccent for consistency
        scaffoldBackgroundColor: Colors.white, // Clean white background
      ),
      home: const Homepage(),
      routes: {
        '/login': (context) => const LogInPage(), // Add a login page route
      },
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  static const List<Widget> _pages = <Widget>[
    HomeScreen(
      user: null,
    ),
    ProfileScreen(user: null,),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _addClass(BuildContext context) async {
  String className = '';

  // Show dialog to input class name
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text("Add New Class"),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AddClassDialogContent(
              onClassNameChanged: (value) => className = value,
              onAddClass: () async {
                if (className.isNotEmpty) {
                  Navigator.of(dialogContext).pop(); // Close input dialog
                  
                  // Add class to Firestore
                  await _addClassToFirestore(className, context);
                } else {
                  _showSnackbar(context, "Class name cannot be empty", Colors.red);
                }
              },
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close dialog
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 239, 239, 240),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          ),
        ],
      );
    },
  );
}

// Method to handle adding class to Firestore
Future<void> _addClassToFirestore(String className, BuildContext context) async {
  try {
    if (_currentUser != null) {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('classes')
          .add({'name': className});

      _showSnackbar(context, "Class added successfully!", Colors.green);
    } else {
      throw Exception("User is not logged in");
    }
  } catch (e) {
    _showSnackbar(context, "Error adding class: $e", Colors.red);
  }
}

// Method to show a Snackbar with a message
void _showSnackbar(BuildContext context, String message, Color color) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}

  Future<void> _logOut() async {
    await _auth.signOut();
    setState(() {
      _currentUser = null; // Set the current user to null
    });
    Navigator.pushReplacementNamed(
        context, '/login'); // Redirect to login route
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Manager'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () {
              _addClass(context);
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            onPressed: _logOut,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(LucideIcons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.user),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer if it's open
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                        user: _currentUser), // Pass the current user
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: _selectedIndex == 0
          ? HomeScreen(user: _currentUser)
          : const ProfileScreen(user: null,),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}

class AddClassDialogContent extends StatefulWidget {
  final ValueChanged<String> onClassNameChanged;
  final Future<void> Function() onAddClass;

  const AddClassDialogContent({
    super.key,
    required this.onClassNameChanged,
    required this.onAddClass,
  });

  @override
  _AddClassDialogContentState createState() => _AddClassDialogContentState();
}

class _AddClassDialogContentState extends State<AddClassDialogContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          onChanged: widget.onClassNameChanged,
          decoration: const InputDecoration(
            hintText: "Enter class name",
            filled: true,
            fillColor: Colors.white70,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8.0),
        ElevatedButton.icon(
          icon: const Icon(LucideIcons.plusCircle),
          onPressed: widget.onAddClass,
          label: const Text("Add Class"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 239, 239, 240),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ], 
    );
  }
}

class HomeScreen extends StatefulWidget {
  final User? user;

  const HomeScreen({super.key, required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> classes = [];

  // Method to delete a class
  Future<void> _deleteClass(String docId) async {
    // Show confirmation dialog before deletion
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Class"),
        content: const Text("Are you sure you want to delete this class?"),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(false), // Return false on cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(true), // Return true on confirm
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Perform Firestore deletion
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user?.uid) // Safely access user.uid now
            .collection('classes')
            .doc(docId)
            .delete();

        // Update the list after deletion
        setState(() {
          classes.removeWhere((classDoc) => classDoc['id'] == docId);
        });
      } catch (e) {
        // Handle any errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete class: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the user is null
    if (widget.user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("You are not logged in"),
            ElevatedButton(
              onPressed: () {
                // Redirect to login page
                Navigator.pushNamed(
                    context, '/login'); // Assuming a login route exists
              },
              child: const Text("Login"),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user?.uid) // Safely access user.uid now
          .collection('classes')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No classes found."));
        }

        classes = snapshot.data!.docs.map((doc) {
          return {
            'id': doc.id, // Get the document ID
            'name': doc['name'],
          };
        }).toList();

        return ListView.builder(
          itemCount: classes.length,
          itemBuilder: (context, index) {
            final classDoc = classes[index];
            final className = classDoc['name'];
            final docId = classDoc['id']; // Document ID

            return AnimatedListItem(
              className: className,
              onDelete: () {
                _deleteClass(docId); // Call the delete function
              },
            );
          },
        );
      },
    );
  }
}

class AnimatedListItem extends StatelessWidget {
  final String className;
  final VoidCallback onDelete;

  const AnimatedListItem({
    super.key,
    required this.className,
    required this.onDelete,
  });

  @override
 Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            // Navigate based on the class name
            switch (className) {
              case 'BCA':
                return StudentListPage();
              case 'English':
                return EnglishPage();
              case 'Math':
                return MathPage();
              // Add more classes as needed
              default:
                return DefaultPage(); // Fallback if no match
            }
          },
        ),
      );
    },
    child: Container(
      width: 300, // Set the desired width
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        elevation: 3.0, // Subtle shadow for a professional look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners for modern appearance
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Padding around the entire card
          child: Column(
            mainAxisSize: MainAxisSize.min, // Prevent overflow
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Custom padding for ListTile
                title: Text(
                  className, // Dynamic class name
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, // Bold class name for emphasis
                    fontSize: 18, // Slightly larger text for class name
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(LucideIcons.trash2), // Trash icon for deleting
                  onPressed: onDelete,
                  color: Colors.red, // Red icon to indicate delete action
                ),
              ),
              const Divider(thickness: 1.0), // Thicker divider for clearer separation
            ],
          ),
        ),
      ),
    ),
  );


  }
}

