import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/firebase_services.dart';

class CountingBookedStudents extends StatefulWidget {
  const CountingBookedStudents({super.key});

  @override
  State<CountingBookedStudents> createState() => _StudentsBookState();
}

class _StudentsBookState extends State<CountingBookedStudents> {
  final FirebaseServices _firebaseServices = FirebaseServices();
  int studentCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentCount();
  }

  Future<void> fetchStudentCount() async {
    try {
      final data = await _firebaseServices.fetchResidences();
      setState(() {
        studentCount = data.length;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load student data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(left: 16, top: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isLoading
          ? const CircularProgressIndicator()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Number of students who have booked:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  "$studentCount",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
    );
  }
}
