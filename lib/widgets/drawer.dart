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
            colors: [
              Color.fromARGB(255, 250, 250, 250), // Soft gradient color
              Color.fromARGB(255, 189, 209, 226),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple,
                    Color.fromARGB(255, 70, 58, 201), // Gradient for header
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(25), // Soft border radius for drawer header
                ),
              ),
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
                radius: 45, // Make avatar bigger for a bold design
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildListItem(
                    icon: Icons.home,
                    title: "Home",
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildListItem(
                    icon: CupertinoIcons.profile_circled,
                    title: "Profile",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildListItem(
                    icon: Icons.settings,
                    title: "Settings",
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildListItem(
                    icon: Icons.notifications,
                    title: "Notifications",
                    color: Colors.teal,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(thickness: 2, color: Colors.grey), // Styled divider
                  _buildListItem(
                    icon: Icons.logout,
                    title: "Logout",
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "App Version: 1.0.0",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build ListTile with custom style
  Widget _buildListItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
      onTap: onTap,
      tileColor: Colors.white, // Background for tiles
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Soft border for the list tiles
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }
}
