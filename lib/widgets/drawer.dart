import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const String imageUrl =
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSKtTkKv8rf5jOTNdhtfcIsP5jJwKj0NAdk8g&s";

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 226, 228, 230), Color.fromARGB(255, 189, 209, 226)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              padding: EdgeInsets.zero,
              child: UserAccountsDrawerHeader(
                margin: EdgeInsets.zero,
                accountName: Text(
                  "Sadaf Ahmed",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  "sadafahmed0078@gmail.com",
                  style: TextStyle(color: Colors.white),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(imageUrl),
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(3),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.black),
              title: const Text(
                "Home",
                textScaleFactor: 1.2,
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                // Add navigation logic for Home
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.profile_circled, color: Colors.black),
              title: const Text(
                "Profile",
                textScaleFactor: 1.2,
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                // Add navigation logic for Profile
                Navigator.pop(context); // Close the drawer
              },
            ),
            const Divider(color: Colors.white), // Divider between items
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                textScaleFactor: 1.2,
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                // Implement logout functionality here
                Navigator.pop(context); // Close the drawer
                // For example, navigate to the login screen
                Navigator.pushNamed(context, '/login'); // Change to your login route
              },
            ),
          ],
        ),
      ),
    );
  }
}
