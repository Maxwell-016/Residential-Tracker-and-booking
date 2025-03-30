import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;


  Future<String> getUserName() async {
    String? email = auth.currentUser?.email;
    if (email == null) return "User";

    var snapshot = await firestore.collection("applicants_details")
        .where("email", isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String? name = snapshot.docs.first.get("name");
      return name ?? "User";
    }
    return "User";
  }


//   Future<List<Map<String, dynamic>>> getHousesByLocation(String location) async {
//     List<Map<String, dynamic>> houses = [];
//
//     QuerySnapshot snapshot = await firestore
//
//         .collectionGroup("Houses") // Searches all "House Details" subcollections
//         .where("Location", isEqualTo: location.toLowerCase()) // Assuming 'location' is a field
//         .get();
//
//     for (var doc in snapshot.docs) {
//       houses.add(doc.data() as Map<String, dynamic>);
//     }
// print(houses);
//     return houses;
//   }

  Future<List<Map<String, dynamic>>> getHousesByLocation(String location) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collectionGroup('Houses') // Fetch houses from all landlords
        .where('Location', isEqualTo: location)
        .get();

    return querySnapshot.docs.map((doc) {
      return {
        "id": doc.id, // House ID
        "landlordId": doc.reference.parent.parent?.id, // Extract landlord ID
        ...doc.data() as Map<String, dynamic>
      };
    }).toList();
  }


  Future<void> bookHouse(String houseId, String landlordId, String paymentOption) async {
    try {
      // Reference to the specific house document in Firestore
      DocumentReference houseRef = firestore
          .collection("Landlords")
          .doc(landlordId)
          .collection("Houses")
          .doc(houseId);

      // Update the `isBooked` field in Firestore
      await houseRef.update({"isBooked": true, "paymentOption": paymentOption});

      print("House $houseId booked successfully!");
    } catch (e) {
      print("Error booking house: $e");
    }
  }



  Future<List<Map<String, dynamic>>> getAllHouses() async {
    List<Map<String, dynamic>> houses = [];

    try {
      QuerySnapshot landlords = await firestore.collection("Landlords").get();

      for (var landlord in landlords.docs) {
        QuerySnapshot housesSnapshot = await landlord.reference.collection("Houses").get();
        for (var house in housesSnapshot.docs) {
          houses.add(house.data() as Map<String, dynamic>);
        }
      }

      print("Retrieved ${houses.length} houses.");
    } catch (e) {
      print("Error fetching houses: $e");
    }

    return houses;
  }



}






class AIService {
  final String apiKey = "AIzaSyBGFC9cnNJEC822NAKicHbX4PJsE1PGn4c";
  final GenerativeModel model;

  AIService() : model = GenerativeModel(
    model: "gemini-2.0-flash",
    apiKey: "AIzaSyBGFC9cnNJEC822NAKicHbX4PJsE1PGn4c",
  );

  Future<String> getAIResponse(String userMessage) async {
    final response = await model.generateContent([Content.text(userMessage)]);
    return response.text ?? "Sorry, I couldn't understand.";
  }
}
