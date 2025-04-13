import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../chartbot_fun/ai_funs.dart';
import '../../../data/chart_provider.dart';
import '../../../data/payment.dart';



void trigernotification(String? token, String body, String title) {
  print("Notification: $title - $body");
}

String? checkoutRequestID;
final FirebaseFirestore fs = FirebaseFirestore.instance;
final FirebaseAuth auth=FirebaseAuth.instance;
final ChatService chatService = ChatService();

class AvailableHousesScreen extends ConsumerWidget {
  final String location;


  const AvailableHousesScreen({
    super.key,
    required this.location,

  });



  Stream<List<Map<String, dynamic>>>streamHousesByLocation(String location) {
    return FirebaseFirestore.instance
        .collectionGroup('Houses')
        .where('Location', isEqualTo: location)
        .where('isBooked', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      return {
        "id": doc.id,
        "landlordId": doc.reference.parent.parent?.id,
        ...doc.data()
      };
    }).toList());
  }

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text("Available Houses in $location")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: streamHousesByLocation(location),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          return buildHouseGrid(snapshot.data!, context,ref);
        },
      ),
    );
  }

  Widget buildHouseGrid(List<Map<String, dynamic>> houses, BuildContext context,ref) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 4 : 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.65,
      ),
      itemCount: houses.length,
      itemBuilder: (context, index) {
        final house = houses[index];
        final images = List<String>.from(house["Images"] ?? []);

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Expanded(
                child: CarouselSlider(
                  options: CarouselOptions(height: 150.0, autoPlay: true),
                  items: images.map((url) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(url, fit: BoxFit.cover, width: double.infinity),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text("Name: ${house['House Name']}"),
                    Text("Price: ${house['House Price']}"),
                    Text("Size: ${house['House Size']}"),
                    Text("Desc: ${house['Description']}"),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => showPaymentDialog(context, house,ref),
                      child: Text("Book"),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> showPaymentDialog(BuildContext context, Map<String, dynamic> house, ref) async {
    final phoneController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    String selectedOption = "first_month";
    String username = await chatService.getUserName();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Complete Payment"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Enter Phone Number",
                    hintText: "e.g., 0712345678",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    String? formatted = validateAndFormatKenyanPhone(value ?? '');
                    if (formatted == null) {
                      return "Enter a valid Kenyan phone number";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedOption,
                  items: ["first_month", "semester"].map((e) {
                    return DropdownMenuItem(value: e, child: Text(e));
                  }).toList(),
                  onChanged: (val) => selectedOption = val!,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Proceed"),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  String? formattedPhone = validateAndFormatKenyanPhone(phoneController.text.trim());
                  Navigator.pop(context); // Close the dialog
                  double amount = selectedOption == "semester"
                      ? house["House Price"] * 4
                      : house["House Price"] * 1;

                  showProcessingDialog(context);

                  DocumentSnapshot landlordDoc = await fs.collection("Landlords").doc(house["landlordId"]).get();
                  String landlordPhone = landlordDoc.exists ? landlordDoc.get("Phone Number") : "Unknown";
                  String lname = landlordDoc.exists ? landlordDoc.get("Name") : "Unknown";

                  initiatePayment(
                      formattedPhone!,
                      amount,
                      auth.currentUser?.email ?? "email",
                      username,
                      house["House Name"],
                      house["Location"],
                      landlordPhone,
                      house["landlordId"],
                      lname,
                      house["id"],
                      List<String>.from(house["Images"]),
                      selectedOption,
                      house["Live Latitude"],
                      house["Live Longitude"],
                      context,
                      ref
                  ).then((_) => Navigator.pop(context)); // hide processing dialog
                }
              },
            )
          ],
        );
      },
    );
  }

  void showProcessingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            String message = "Processing payment...";
            int secondsPassed = 0;

            Timer.periodic(Duration(seconds: 5), (timer) {
              if (!Navigator.of(context).canPop()) {
                timer.cancel();
                return;
              }
              secondsPassed += 5;
              setState(() {
                message = "Waiting for M-Pesa... ($secondsPassed secs)";
              });
            });

            return AlertDialog(
              title: Text("Please wait"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text(message),
                ],
              ),
            );
          },
        );
      },
    );
  }



 }
