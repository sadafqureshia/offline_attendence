import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DefaultPage extends StatefulWidget {
  final String departmentName;

  const DefaultPage({required this.departmentName, super.key});

  @override
  _DefaultPageState createState() => _DefaultPageState();
}

class _DefaultPageState extends State<DefaultPage> {
  final List<Map<String, dynamic>> students = [];
  String searchQuery = "";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isDownloading = false;
  bool isLoading = false; // To track loading state

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    setState(() {
      isLoading = true; // Set loading to true
    });

    try {
      QuerySnapshot querySnapshot = await _firestore.collection(widget.departmentName).get();
      setState(() {
        students.clear();
        for (var doc in querySnapshot.docs) {
          students.add({
            'name': doc['name'],
            'auid': doc['auid'],
            'status': 'Absent', // Default status
            'id': doc.id,
          });
        }
      });
    } catch (e) {
      // Handle errors here
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch students: $e")),
        );
      });
    } finally {
      setState(() {
        isLoading = false; // Set loading to false
      });
    }
  }

  void addStudent(String name, String auid) {
    _firestore.collection(widget.departmentName).add({'name': name, 'auid': auid}).then((_) {
      fetchStudents();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student added")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add student: $error")),
      );
    });
  }

  void markAttendance(int index, String status) {
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
    await _firestore.collection(widget.departmentName).doc(id).delete().then((_) {
      setState(() {
        students.removeAt(index); // Remove from local list
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student deleted")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete student: $error")),
      );
    });
  }

  Future<void> downloadCSV() async {
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
    final safeDepartmentName = widget.departmentName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final path = '${directory.path}/attendance_${safeDepartmentName}_${DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-')}.csv';

    File file = File(path);
    await file.writeAsString(csv);

    setState(() {
      isDownloading = false; // Download complete
    });

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
                if (nameController.text.isNotEmpty && auidController.text.isNotEmpty) {
                  addStudent(nameController.text, auidController.text);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in all fields")),
                  );
                }
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
        .where((student) => student['name'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.departmentName} Department - Student List"),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onLongPress: () {
                          deleteStudent(filteredStudents[index]['id'], students.indexOf(filteredStudents[index]));
                        },
                        child: Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text('${filteredStudents[index]['name']}'),
                            subtitle: Text('AUID: ${filteredStudents[index]['auid']}\nStatus: ${filteredStudents[index]['status']}'),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check),
                                  color: Colors.green,
                                  onPressed: () => markAttendance(students.indexOf(filteredStudents[index]), 'Present'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  color: Colors.red,
                                  onPressed: () => markAttendance(students.indexOf(filteredStudents[index]), 'Absent'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isDownloading ? null : downloadCSV,
                  icon: const Icon(Icons.download),
                  label: Text(isDownloading ? "Downloading..." : "Download CSV"),
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
