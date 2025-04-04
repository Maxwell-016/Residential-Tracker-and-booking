import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../View/Screens/Student/mapscreen.dart';

class BookedHousesScreen extends StatefulWidget {
  const BookedHousesScreen({super.key});

  @override
  State<BookedHousesScreen> createState() => _BookedHousesScreenState();
}

class _BookedHousesScreenState extends State<BookedHousesScreen> {
  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();
  final TextEditingController feedbackController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;




  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings =
    InitializationSettings(android: androidInitSettings);
    _notifications.initialize(initSettings);
  }

  Future<void> _sendNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails('reminder_channel', 'Reminders',
        importance: Importance.high, priority: Priority.high);
    const NotificationDetails details =
    NotificationDetails(android: androidDetails);
    await _notifications.show(0, title, body, details);
  }

  Future<void> _sendEmailReminder(String recipientEmail) async {
    final Email email = Email(
      body: "Your house booking is about to expire! Please make a payment to continue staying.",
      subject: "Urgent: House Booking Expiry",
      recipients: [recipientEmail],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      print("Error sending email: $error");
    }
  }

  Future<void> _makePayment(String phoneNumber, String docId, int amount) async {
    final Uri url = Uri.parse("https://mpesaapi.onrender.com/stkpush");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phoneNumber, "amount": amount}),
    );

    if (response.statusCode == 200) {
      await FirebaseFirestore.instance
          .collection("booked_students")
          .doc(docId)
          .update({"payment_status": "Paid", "timestamp": Timestamp.now()});
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Payment Successful!")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Payment Failed. Try again.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    String? userEmail = _auth.currentUser?.email;

    return Scaffold(
      appBar: AppBar(title: Text("My Booked House(s)")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("booked_students")
            .where("email", isEqualTo: userEmail)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No booked houses found."));
          }

          // var bookedHouses = snapshot.data!.docs;

          return ListView(
            padding: EdgeInsets.all(10),
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              Timestamp? timestamp = doc['timestamp'];
              String paymentOption = doc['paymentOption'];
              String status = doc['payment_status'];
              String email = doc['email'];
              String docId = doc.id;
              String houseName = doc['houseName'];
              List<dynamic> images = doc['images'];
              String location = doc['houseLocation'];
              String landlord = doc["landlord"];
              String land = doc["landlordId"];
              String landlordContact = doc["landlordContact"];


              DateTime paymentDate = timestamp?.toDate() ?? DateTime.now();
              int paidMonths = (paymentOption == "semester") ? 4 : 1;
              DateTime expiryDate = paymentDate.add(Duration(days: paidMonths * 30));
              int daysRemaining = expiryDate.difference(DateTime.now()).inDays;

              if (daysRemaining == 29) {
                _sendNotification("Payment Reminder", "Your house booking expires today!");
                _sendEmailReminder(email);
              }

              return Card(
                elevation: 16,
                margin: EdgeInsets.all(18),

                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (images.isNotEmpty)
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 250,
                        aspectRatio: 16 / 9,
                        autoPlay: true,
                        enlargeCenterPage: true,
                      ),
                      items: images.map((image) {
                        return ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            image,
                            width: double.infinity,
                            fit: BoxFit.fill,
                          ),
                        );
                      }).toList(),
                    ),


                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(houseName,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Text(
                            "📍 Location: $location",
                            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          ),
                          Text(
                            "👤 Landlord: $landlord",
                            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "📞 Contact: $landlordContact",
                            style: TextStyle(fontSize: 16, color: Colors.blue),
                          ),


                          SizedBox(height: 10),

                          Text(
                            "🕒 Days Remaining: $daysRemaining days",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: daysRemaining <= 3 ? Colors.red : Colors.green,
                            ),
                          ),
                          SizedBox(height: 10),


                          // Payment Status
                          Text(
                            "Status: ${status == "Paid" ? "✅ Paid" : "❌ Not Paid"}",
                            style: TextStyle(
                                color: status == "Paid" ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold),
                          ),


                          if (status != "Paid")
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                "⚠️ Your house will be unbooked after 5 days without payment!",
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ),

                          SizedBox(height: 10),


                          if (status != "Paid")
                            ElevatedButton.icon(
                              onPressed: () {
                                _showPaymentDialog(docId);
                              },
                              icon: Icon(Icons.payment),
                              label: Text("Make Payment"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                            ),

                          SizedBox(height: 5),

                          ListTile(
                            leading:
                          ElevatedButton.icon(
                            onPressed: () {
                              _showHouseOnMap(data['lat'], data['long'], houseName, images[0], location);
                            },
                            icon: Icon(Icons.map),
                            label: Text("Show Surroundings"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          ),
                          trailing:ElevatedButton.icon(
                            icon: Icon(Icons.feedback),
                            label: Text("Send Feedback"),
                            onPressed: () => showFeedbackDialog(doc.id, landlord,land),
                          ),

                          )

                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void showFeedbackDialog(String houseId, String landlord,String land) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text("Send Feedback to $landlord"),
            content: TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter your feedback here...",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (feedbackController.text.isNotEmpty) {
                    await sendFeedback(houseId,land);
                    Navigator.pop(context);
                  }
                },
                child: Text("Submit"),
              ),
            ],
          ),
    );
  }


  /// Send Feedback to Firebase
  Future<void> sendFeedback(String houseId,String land) async {
    String? email = _auth.currentUser?.email;
    if (email == null) return;

    await FirebaseFirestore.instance.collection("house_feedback").add({
      "houseId": houseId,
      "userEmail": email,
      "landlordId":land,
      "feedback": feedbackController.text,
      "timestamp": FieldValue.serverTimestamp(),
    });

    feedbackController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Feedback submitted successfully!")),
    );
  }





  void _showPaymentDialog(String docId) {
    String phoneNumber = "";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Make Payment"),
          content: TextField(
            onChanged: (value) => phoneNumber = value,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: "Enter Phone Number"),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _makePayment(phoneNumber, docId, 3500);
              },
              child: Text("Pay Now"),
            ),
          ],
        );
      },
    );
  }

  void _showHouseOnMap(double lat, double long, String houseName, String imageUrl, String location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreenHouses(
          title: "My Booked house",
          houses: [
            {"houseName": houseName, "lat": lat, "long": long, "image": imageUrl, "location": location}
          ],
        ),
      ),
    );
  }
}
