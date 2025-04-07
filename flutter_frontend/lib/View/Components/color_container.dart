import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentListScreen extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: fetchLocations(firestore),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var locations = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              var locationData = locations[index];
              String locationName = locationData['name'];
              int studentCount = locationData['students'];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  decoration: BoxDecoration(
                    color: getUniqueColor(locationName).withOpacity(0.3),
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        locationName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'No of students: $studentCount',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Fetches locations from Firestore
  Future<List<Map<String, dynamic>>> fetchLocations(
      FirebaseFirestore firestore) async {
    QuerySnapshot snapshot = await firestore.collection('locations').get();
    return snapshot.docs.map((doc) {
      return {
        'name': doc['name'],
        'students': doc['students'],
      };
    }).toList();
  }

  // Assigns a unique color based on location name
  Color getUniqueColor(String locationName) {
    List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.teal,
      Colors.amber,
      Colors.pink,
      Colors.lime,
    ];
    int hash = locationName.hashCode
        .abs(); // Generates a consistent hash for each name
    return colors[hash % colors.length]; // Selects a color based on the hash
  }
}
