import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;



  Future<String> welcome() async {
    String? email = auth.currentUser?.email;
    if (email == null) return  "Welcome! How can I help you today?";

    var snapshot = await firestore.collection("applicants_details")
        .where("email", isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String? name = snapshot.docs.first.get("name");


      return name != null && name.isNotEmpty?
      "Welcome $name! I am your assistant to help you find the house of your choice.\n\n"
          "Here are the services we offer:\n"
          " 1 List all available houses in a specific location\n"
          " 2 See all locations with available houses\n"
          " 3 Report for an emergency\n"
          " 4 Ask for help and related questions\n"
          "\n"
          "Which option would you like me to assist you with? (Reply with 1 or 2)":
      "I see you haven't provided a name. Please enter your full name:";

    }
    return "I couldn't find your details. Please enter your full name:";
  }



  bool isValidFullName(String name) {
    return RegExp(r"^[A-Za-z]+(?: [A-Za-z]+)+$").hasMatch(name);
  }


  Future<void> saveName(String name) async {
    String? email = auth.currentUser?.email;
    if (email == null) return;

    await firestore.collection("applicants_details").doc(email).set(
      {
        "name": name,
        "email": email,
      },
      SetOptions(merge: true),
    );
  }



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







  Future<List<Map<String, dynamic>>> getHousesByLocation(String location) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collectionGroup('Houses') // Fetch houses from all landlords
        .where('Location', isEqualTo: location)
        .where("isBooked",isEqualTo: false)
        .get();

    return querySnapshot.docs.map((doc) {
      return {
        "id": doc.id, // House ID
        "landlordId": doc.reference.parent.parent?.id, // Extract landlord ID
        ...doc.data() as Map<String, dynamic>
      };
    }).toList();
  }





  Future<List<Map<String, dynamic>>> getAllHouses() async {
    List<Map<String, dynamic>> houses = [];

    try {
      QuerySnapshot landlords = await firestore.collection("Landlords").get();

      for (var landlord in landlords.docs) {
        String landlordId = landlord.id;


        QuerySnapshot housesSnapshot = await landlord.reference.collection("Houses").get();

        for (var house in housesSnapshot.docs) {
          var houseData = house.data() as Map<String, dynamic>;

          houseData["id"] = house.id;
          houseData["landlordId"] = landlordId;

          houses.add(houseData);
        }
      }

      print("Retrieved ${houses.length} houses.");
    } catch (e) {
      print("Error fetching houses: $e");
    }

    return houses;
  }



  Future<void> savePhoneNumber(String phoneNumber) async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email != null) {
      DocumentReference docRef = FirebaseFirestore.instance.collection("applicants_details").doc(email);

      await docRef.set({
        "phone": phoneNumber,
      }, SetOptions(merge: true)); // Ensures existing data is not lost
    }
  }



  Future<String?> getUserPhone() async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return null;

    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("applicants_details").doc(email).get();
    return doc.exists ? doc["phone"] : null;
  }



// Future<void> bookHouse(String houseId, String landlordId, String paymentOption) async {
  //   try {
  //     // Reference to the specific house document in Firestore
  //     DocumentReference houseRef = firestore
  //         .collection("Landlords")
  //         .doc(landlordId)
  //         .collection("Houses")
  //         .doc(houseId);
  //
  //     // Update the `isBooked` field in Firestore
  //     await houseRef.update({"isBooked": true, "paymentOption": paymentOption});
  //
  //     print("House $houseId booked successfully!");
  //   } catch (e) {
  //     print("Error booking house: $e");
  //   }
  // }
  //
  //
  // //
  // Future<void> initiatePayment(Map<String, dynamic> house, String paymentOption) async {
  //   String? email = auth.currentUser?.email;
  //   if (email == null) return;
  //
  //   DocumentSnapshot landlordDoc = await firestore.collection("Landlords").doc(house["landlordId"]).get();
  //   String landlordPhone = landlordDoc.get("Phone Number");
  //   String name = landlordDoc.get("Name");
  //
  //   var response = await http.post(
  //     Uri.parse("https://mpesaapi.onrender.com/stkpush"),
  //     headers: {"Content-Type": "application/json"},
  //     body: jsonEncode({
  //       "phone": "STUDENT_PHONE_NUMBER",
  //       "amount": house["House Price"]/1000,
  //       "callbackUrl": "https://mpesaapi.onrender.com/callback",
  //     }),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     await http.get(Uri.parse("https://mpesaapi.onrender.com/callback"));
  //
  //     await firestore.collection("booked_students").doc(email).set({
  //       "email": email,
  //       "name": auth.currentUser?.displayName ?? "Unknown",
  //       "stdContact": "STUDENT_PHONE_NUMBER",
  //       "houseName": house["House Name"],
  //       "houseLocation": house["Location"],
  //       "payment_status": "Paid",
  //       "amount_paid": house["House Price"],
  //       "landlordContact": landlordPhone,
  //       "landlord":name,
  //     });
  //
  //     await firestore.collection("Landlords").doc(house["landlordId"])
  //         .collection("Houses").doc(house["id"])
  //         .update({"isBooked": true});
  //   }
  // }
  //
  //




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
