// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:lucide_icons/lucide_icons.dart';

// class AttendanceSummaryScreen extends StatefulWidget {
//   @override
//   _AttendanceSummaryScreenState createState() => _AttendanceSummaryScreenState();
// }

// class _AttendanceSummaryScreenState extends State<AttendanceSummaryScreen> {
//   User? user;
//   List<Map<String, dynamic>> dailyAttendance = [];

//   // Fetch Attendance Summary Data
//   Future<Map<String, dynamic>> _fetchAttendanceSummary() async {
//     final uid = user!.uid;
//     final attendanceRef = FirebaseFirestore.instance
//         .collection('users')
//         .doc(uid)
//         .collection('attendanceSummary');

//     QuerySnapshot attendanceSnapshot = await attendanceRef.get();
//     int totalClasses = 0;
//     int attendedClasses = 0;
//     int lateCount = 0;
//     int excusedCount = 0;

//     // Calculating from data
//     for (var doc in attendanceSnapshot.docs) {
//       Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//       totalClasses += data['totalClasses'] ?? 0;
//       attendedClasses += data['attendedClasses'] ?? 0;
//       if (data['status'] == 'Late') lateCount++;
//       if (data['status'] == 'Excused') excusedCount++;
//     }

//     double attendancePercentage = (attendedClasses / totalClasses) * 100;

//     return {
//       'totalClasses': totalClasses,
//       'attendedClasses': attendedClasses,
//       'attendancePercentage': attendancePercentage,
//       'lateCount': lateCount,
//       'excusedCount': excusedCount,
//     };
//   }

//   // Fetch Daily Attendance Data
//   Future<void> _fetchDailyAttendance() async {
//     final uid = user!.uid;
//     final attendanceRef = FirebaseFirestore.instance
//         .collection('users')
//         .doc(uid)
//         .collection('attendanceSummary');

//     QuerySnapshot attendanceSnapshot = await attendanceRef.get();

//     setState(() {
//       dailyAttendance = attendanceSnapshot.docs.map((doc) {
//         return {
//           'date': doc.id,
//           'subject': doc['subject'],
//           'status': doc['status'],
//         };
//       }).toList();
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     user = FirebaseAuth.instance.currentUser;
//     _fetchDailyAttendance();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student Attendance'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Attendance Summary',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             FutureBuilder<Map<String, dynamic>>(
//               future: _fetchAttendanceSummary(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const CircularProgressIndicator();
//                 }
//                 var summary = snapshot.data!;
//                 return GridView.count(
//                   crossAxisCount: 2,
//                   shrinkWrap: true,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                   children: [
//                     _buildSummaryCard('Total Classes', summary['totalClasses']),
//                     _buildSummaryCard('Attended Classes', summary['attendedClasses']),
//                     _buildSummaryCard('Attendance %', summary['attendancePercentage'].toStringAsFixed(2)),
//                     _buildSummaryCard('Late', summary['lateCount']),
//                     _buildSummaryCard('Excused', summary['excusedCount']),
//                   ],
//                 );
//               },
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Daily Attendance',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: dailyAttendance.length,
//                 itemBuilder: (context, index) {
//                   var attendance = dailyAttendance[index];
//                   return ListTile(
//                     leading: Icon(
//                       attendance['status'] == 'Present'
//                           ? LucideIcons.checkCircle
//                           : (attendance['status'] == 'Late'
//                               ? LucideIcons.clock
//                               : LucideIcons.xCircle),
//                       color: attendance['status'] == 'Present' ? Colors.green : Colors.red,
//                     ),
//                     title: Text('${attendance['date']} - ${attendance['subject']}'),
//                     subtitle: Text('Status: ${attendance['status']}'),
//                   );
//                 },
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 // Logic for Check-In functionality
//               },
//               child: const Text('Check-In'),
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper function to build summary card
//   Widget _buildSummaryCard(String title, dynamic value) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title, style: const TextStyle(fontSize: 16)),
//             const SizedBox(height: 10),
//             Text(
//               value.toString(),
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
