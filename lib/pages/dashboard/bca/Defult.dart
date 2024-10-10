// student_list_page.dart
import 'package:flutter/material.dart';

class DefaultPage extends StatelessWidget {
  // Dummy list of students
  final List<String> students = ['sadaf'];

   DefaultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student List"),
      ),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(students[index]), // Student name
            onTap: () {
              // You can add more functionality when a student is tapped
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Clicked on ${students[index]}")),
              );
            },
          );
        },
      ),
    );
  }
}
