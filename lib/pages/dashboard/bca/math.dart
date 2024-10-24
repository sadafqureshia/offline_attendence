import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart'; // For date formatting

class MathPage extends StatefulWidget {
  const MathPage({super.key});

  @override
  _MathPageState createState() => _MathPageState();
}

class _MathPageState extends State<MathPage> {
  final List<Map<String, dynamic>> students = [];
  String searchQuery = "";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isDownloading = false; // To track download status
  DateTime today = DateTime.now(); // For keeping track of today's date

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(today);

    QuerySnapshot querySnapshot = await _firestore
        .collection('math_students')
        .doc(formattedDate) // Get the collection for today
        .collection('students')
        .get();

    if (querySnapshot.docs.isEmpty) {
      // No attendance found for today, set all to 'Absent'
      await _firestore.collection('math_students').doc(formattedDate).set({});
    }

    setState(() {
      students.clear();
      for (var doc in querySnapshot.docs) {
        students.add({
          'name': doc['name'],
          'auid': doc['auid'],
          'status': doc['status'] ?? 'Absent', // Default status
          'id': doc.id, // Store Firestore document ID for deletion
        });
      }
    });
  }

  void addStudent(String name, String auid) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(today);
    _firestore
        .collection('math_students')
        .doc(formattedDate)
        .collection('students')
        .add({'name': name, 'auid': auid, 'status': 'Absent'}).then((_) {
      fetchStudents();
    });
  }

  void markAttendance(int index, String status) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(today);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mark Attendance'),
          content: Text('Mark ${students[index]['name']} as $status?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  students[index]['status'] = status; // Update the status
                });
                _firestore
                    .collection('math_students')
                    .doc(formattedDate)
                    .collection('students')
                    .doc(students[index]['id'])
                    .update({'status': status}); // Update Firestore
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteStudent(String id, int index) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(today);

    await _firestore
        .collection('math_students')
        .doc(formattedDate)
        .collection('students')
        .doc(id)
        .delete(); // Delete from Firestore

    setState(() {
      students.removeAt(index); // Remove from local list
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Student deleted")),
    );
  }

  Future<void> downloadCSV() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    setState(() {
      isDownloading = true; // Start downloading
    });

    List<List<dynamic>> csvData = [
      ['Name', 'AUID', 'Status']
    ];

    for (var student in students) {
      csvData.add([student['name'], student['auid'], student['status']]);
    }

    String csv = const ListToCsvConverter().convert(csvData);
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/math_attendance_${DateFormat('yyyyMMdd').format(today)}.csv';
    File file = File(path);
    await file.writeAsString(csv);

    setState(() {
      isDownloading = false; // Download complete
    });

    Navigator.of(context).pop(); // Close loading dialog

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("CSV downloaded to $path")),
    );
  }

  void showAddStudentDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController auidController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: auidController,
                decoration: const InputDecoration(labelText: 'AUID'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                addStudent(nameController.text, auidController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = students
        .where((student) =>
            student['name'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Math Student List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: isDownloading ? null : downloadCSV, // Download CSV
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: "Search Students...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onLongPress: () {
                    deleteStudent(filteredStudents[index]['id'],
                        students.indexOf(filteredStudents[index]));
                  },
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text('${filteredStudents[index]['name']}'),
                      subtitle: Text(
                          'AUID: ${filteredStudents[index]['auid']}\nStatus: ${filteredStudents[index]['status']}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              markAttendance(
                                  students.indexOf(filteredStudents[index]),
                                  'Present');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              markAttendance(
                                  students.indexOf(filteredStudents[index]),
                                  'Absent');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isDownloading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddStudentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
