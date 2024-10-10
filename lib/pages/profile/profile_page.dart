import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  final User? user;

  const ProfileScreen({super.key, required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ImagePicker _picker = ImagePicker();

  String? username;
  String? profilePictureUrl;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (widget.user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(widget.user!.uid).get();

        if (userDoc.exists) {
          setState(() {
            username = userDoc['username'] ?? 'No username set';
            profilePictureUrl = userDoc['profilePicture'] ?? widget.user!.photoURL;
          });
        } else {
          setState(() {
            username = 'No username set';
            profilePictureUrl = widget.user!.photoURL;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch user data: $e")),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    final newUsername = await _showUsernameDialog(username);
    if (newUsername != null && newUsername.isNotEmpty) {
      try {
        print('Updating username for UID: ${widget.user!.uid}');
        await _firestore.collection('users').doc(widget.user!.uid).update({'username': newUsername});
        setState(() {
          username = newUsername; // Update the state with the new username
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username updated successfully")),
        );
      } catch (e) {
        print('Failed to update username: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update username: $e")),
        );
      }
    }
  }

  Future<void> _changeProfilePicture() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });

        String newProfilePicUrl = await _uploadImageToFirebase(_profileImage!);
        await _firestore.collection('users').doc(widget.user!.uid).update({'profilePicture': newProfilePicUrl});
        setState(() {
          profilePictureUrl = newProfilePicUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No image selected")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: $e")),
      );
    }
  }

  Future<String> _uploadImageToFirebase(File image) async {
    String filePath = 'profile_pictures/${widget.user!.uid}/${DateTime.now().millisecondsSinceEpoch}';
    TaskSnapshot snapshot = await FirebaseStorage.instance.ref(filePath).putFile(image);
    return await snapshot.ref.getDownloadURL();
  }

  Future<String?> _showUsernameDialog(String? currentUsername) async {
    TextEditingController controller = TextEditingController(text: currentUsername);
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Change Username"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter new username"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text.trim()); // Trim the input
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _changeProfilePicture,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: profilePictureUrl != null
                        ? NetworkImage(profilePictureUrl!)
                        : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 30), // Camera icon overlay
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  username ?? "Loading...",
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Change Username"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.deepPurple, // Text color
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onPressed: _updateProfile,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.red, // Text color
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onPressed: _logOut,
                ),
                const SizedBox(height: 30),
                const Divider(color: Colors.grey),
                const SizedBox(height: 20),
                const Text(
                  "User Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Text(
                  "User ID: ${widget.user?.uid}",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 5),
                Text(
                  "Email: ${widget.user?.email}",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
