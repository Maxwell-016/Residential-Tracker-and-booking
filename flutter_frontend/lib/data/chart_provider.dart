import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;



  bool isLegitPlace(String name) {
    final regex = RegExp(r'^[A-Za-z][A-Za-z\s]*$');
    return regex.hasMatch(name);
  }


  Future<String> welcome() async {
    String? email = auth.currentUser?.email;
    if (email == null) return "Welcome! How can I help you today?";

    var snapshot = await firestore
        .collection("applicants_details")
        .where("email", isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String? name = snapshot.docs.first.get("name");



      return name != null && name.isNotEmpty
          ? "Welcome ${name.trim().split(" ").first}, I am your assistant to help you find the house of your choice.\n\n"
              "Here are the services we offer:\n"
              " 1 List all available houses in a specific location\n"
              " 2 See all locations with available houses\n"
              " 3 Report for an emergency\n"
              " 4 Search for available  houses by specifications\n"
              " 5 See all vacant houses\n\n"
              "Which option would you like me to assist you with? (Reply with one of the above options eg 1 or option 1)"
          : "I see you haven't provided a name. Please enter your full name:";
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
    if (email == null) return "user";

    var snapshot = await firestore
        .collection("applicants_details")
        .where("email", isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String? name = snapshot.docs.first.get("name");

      return name != null && name.isNotEmpty ? name : "user";
    }
    return "user";
  }

  bool userWantsToGoBack(String message) {
    final lowerMsg = message.toLowerCase();
    return [
      "go back",
      "back to menu",
      "back to options",
      "return to services",
      "i want another option",
      "show services",
      "main menu",
      "back",
    ].any((phrase) => lowerMsg.contains(phrase));
  }



  Future<List<Map<String, dynamic>>> getHouses() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collectionGroup('Houses')
        .where("isBooked", isEqualTo: false)
        .get();

    return querySnapshot.docs.map((doc) {
      return {
        "id": doc.id,
        "landlordId": doc.reference.parent.parent?.id,
        ...doc.data() as Map<String, dynamic>
      };
    }).toList();
  }




  Future<List<Map<String, dynamic>>> getHousesByLocation(
      String location) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collectionGroup('Houses')
        .where('Location', isEqualTo: location)
        .where("isBooked", isEqualTo: false)
        .get();

    return querySnapshot.docs.map((doc) {
      return {
        "id": doc.id, // House ID
        "landlordId": doc.reference.parent.parent?.id,
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

        QuerySnapshot housesSnapshot =
            await landlord.reference.collection("Houses").get();

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





  Future<List<Map<String, dynamic>>> getHousesByPriceRange(int min, int max) async {
    final snapshot = await firestore
        .collectionGroup('Houses')
        .where("isBooked", isEqualTo: false)
        .get();

    print(snapshot);
    return snapshot.docs
        .map((e) => e.data() as Map<String, dynamic>)
        .where((house) =>
        house["House Price"] != null &&
       // house["House Price"] is double &&
        house["House Price"] >= min &&
        house["House Price"] <= max)
        .toList();
  }


  Future<List<Map<String, dynamic>>> getHousesByAmenity(String keyword) async {
    final snapshot = await firestore
        .collectionGroup('Houses')
        .where("isBooked", isEqualTo: false)
        .get();

    return snapshot.docs
        .map((e) => e.data())
        .where((house) =>
    house["Amenities"] != null &&
        house["Amenities"].toString().toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getHousesByDescription(String keyword) async {
    final snapshot = await firestore
        .collectionGroup('Houses')
        .where("isBooked", isEqualTo: false)
        .get();

    return snapshot.docs
        .map((e) => e.data())
        .where((house) =>
    house["Description"] != null &&
        house["Description"].toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }







  Future<void> savePhoneNumber(String phoneNumber) async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email != null) {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection("applicants_details")
          .doc(email);
      await docRef.set({
        "phone": phoneNumber,
      }, SetOptions(merge: true)); // Ensures existing data is not lost
    }
  }

  Future<String?> getUserPhone() async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return null;

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("applicants_details")
        .doc(email)
        .get();
    return doc.exists ? doc["phone"] : null;
  }




  Future<List<String>> getAllLocations() async {
    Set<String> uniqueLocations = {};

    try {
      QuerySnapshot landlords = await firestore.collection("Landlords").get();

      for (var landlord in landlords.docs) {
        QuerySnapshot housesSnapshot =
            await landlord.reference.collection("Houses").get();

        for (var house in housesSnapshot.docs) {
          var houseData = house.data() as Map<String, dynamic>;

          if (!(houseData["isBooked"] ?? true) &&
              houseData.containsKey("Location")) {
            uniqueLocations.add(houseData["Location"]);
          }
        }
      }

      print("found $uniqueLocations");
    } catch (e) {
      print("Error fetching locations: $e");
    }
    return uniqueLocations.toList();
  }




  Future<String> handleOption2() async {
    List<String> locations = await getAllLocations();

    if (locations.isEmpty) {
      return "Currently, there are no available houses in any location.";
    }
    String locationList = locations
        .asMap()
        .entries
        .map((e) => "${e.key + 1}. ${e.value}")
        .join("\n");

    return "Here are the locations with available houses:\n$locationList\n\n"
        "Would you like to see the available houses in a specific location? (Reply with the location name)";
  }
}

class AIService {
  final String apiKey = "AIzaSyBGFC9cnNJEC822NAKicHbX4PJsE1PGn4c";
  final GenerativeModel model;

  AIService()
      : model = GenerativeModel(
          model: "gemini-2.0-flash",
          apiKey: "AIzaSyBGFC9cnNJEC822NAKicHbX4PJsE1PGn4c",
        );

  Future<String> getAIResponse(String userMessage) async {
    final response = await model.generateContent([Content.text(userMessage)]);
    return response.text ?? "Sorry, I couldn't understand.";
  }
}
