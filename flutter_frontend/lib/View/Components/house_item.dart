

import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/payment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../data/chart_provider.dart';
import '../../data/notifications.dart';

class HouseCard extends ConsumerStatefulWidget {
  const HouseCard({required this.house, super.key});
  final Map<String, dynamic> house;

  @override
  ConsumerState<HouseCard> createState() => _StateHouseCard();
}

class _StateHouseCard extends ConsumerState<HouseCard> {
  bool isBooking = false;
  String? selectedPayment;
  String? studentPhone;
  final ChatService chatService = ChatService();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fs = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchStudentPhone();
  }

  Future<void> _fetchStudentPhone() async {
    String? phone = await chatService.getUserPhone();
    setState(() {
      studentPhone = phone;
    });
  }

  Future<void> startBookHouse() async {
    setState(() => isBooking = true);

    String? landlordId = widget.house["landlordId"] as String?;
    String? houseId = widget.house["id"] as String?;

    if (landlordId == null || houseId == null) {
      print("Error: LandlordId or HouseId is null");
      setState(() => isBooking = false);
      return;
    }

  //  if (studentPhone == null || studentPhone!.isEmpty) {
      await _promptForPhoneNumber();
      // if (studentPhone == null || studentPhone!.isEmpty) {
      //   print("Phone number not provided.");
      //   setState(() => isBooking = false);
      //   return;
      // }
   // }

    _showPaymentOptions();
    setState(() => isBooking = false);
  }

  Future<void> _promptForPhoneNumber() async {
    String? phoneNumber = await showDialog<String>(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text("Enter Phone Number For Payment"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: "e.g., 2547XXXXXXXX",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text("Send"),
            ),
          ],
        );
      },
    );

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      setState(() => studentPhone = phoneNumber);
      await fs.collection("applicants_details").doc(auth.currentUser?.email).set(
        {"phone": studentPhone},
        SetOptions(merge: true),
      );
    }
  }

  Future<void> cancelBooking() async {
    setState(() => isBooking = true);

    String? landlordId = widget.house["landlordId"] as String?;
    String? houseId = widget.house["id"] as String?;

    if (landlordId == null || houseId == null) {
      print("Error: LandlordId or HouseId is null");
      setState(() => isBooking = false);
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("Landlords")
          .doc(landlordId)
          .collection("Houses")
          .doc(houseId)
          .update({"isBooked": false});

      setState(() {
        widget.house["isBooked"] = false;
      });

      print("Booking canceled successfully.");
    } catch (e) {
      print("Error canceling booking: $e");
    }

    setState(() => isBooking = false);
  }





  void _showPaymentOptions() {
    double housePrice = widget.house["House Price"]?? 0.0;
    double monthlyPayment = housePrice;
    double semesterPayment = (housePrice * 4);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Payment Option"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("Pay for the first month - Ksh $monthlyPayment"),
              leading: Radio<String>(
                value: "first_month",
                groupValue: selectedPayment,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedPayment = value);
                    Navigator.pop(context);
                    _processBooking(value);
                  }
                },
              ),
            ),
            ListTile(
              title: Text("Pay per semester - Ksh $semesterPayment"),
              leading: Radio<String>(
                value: "semester",
                groupValue: selectedPayment,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedPayment = value);
                    Navigator.pop(context);
                    _processBooking(value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> markHouseAsBooked(String landlordId, String houseId) async {
    final houseRef = FirebaseFirestore.instance
        .collection("Landlords")
        .doc(landlordId)
        .collection("Houses")
        .doc(houseId);

    await houseRef.update({"isBooked": true});
  }
  Future<void> markHouseAsUnbooked(String landlordId, String houseId) async {
    final houseRef = FirebaseFirestore.instance
        .collection("Landlords")
        .doc(landlordId)
        .collection("Houses")
        .doc(houseId);

    await houseRef.update({"isBooked": false});
  }


  Future<void> bookHouse(String paymentOption) async {
    setState(() => isBooking = true);

    String? landlordId = widget.house["landlordId"] as String?;
    String? houseId = widget.house["id"] as String?;

    if (landlordId == null || houseId == null) {
      print("Error: LandlordId or HouseId is null");
      setState(() => isBooking = false);
      return;
    }

    try {
      // await FirebaseFirestore.instance
      //     .collection("Landlords")
      //     .doc(landlordId)
      //     .collection("Houses")
      //     .doc(houseId)
      //     .update({"isBooked": true});

      markHouseAsBooked(landlordId, houseId);

      setState(() {
        widget.house["isBooked"] = true;
      });

      print("House booked successfully.");
    } catch (e) {
      print("Error booking house: $e");
    }

    setState(() => isBooking = false);
  }

  Future<void> _processBooking(String paymentOption) async {
    setState(() => isBooking = true);

    String? landlordId = widget.house["landlordId"] as String?;
    String? houseId = widget.house["id"] as String?;
    String houseName = widget.house["House Name"] ?? "Unknown House";
    double lat = widget.house["Live Latitude"] ?? 0.0;
    double long = widget.house["Live Longitude"] ?? 0.0;
    String location = widget.house["Location"] ?? "Unknown Location";
    double price = widget.house["House Price"] ?? 0.0;
    List<String> houseImage = widget.house["Images"].cast<String>() ?? [];

    String? studentEmail = auth.currentUser?.email;
    String? studentName = await chatService.getUserName();
    String? studentPhone = await chatService.getUserPhone();

    if (studentPhone == null || studentPhone.isEmpty) {
      await _promptForPhoneNumber();
      if (studentPhone == null || studentPhone!.isEmpty) {
        print("Phone number not provided.");
        setState(() => isBooking = false);
        return;
      }
    }


    DocumentSnapshot landlordDoc = await fs.collection("Landlords").doc(landlordId).get();
    String landlordPhone = landlordDoc.exists ? landlordDoc.get("Phone Number") : "Unknown";
    String landlordName = landlordDoc.exists ? landlordDoc.get("Name") : "Unknown";
    double amountToPay = paymentOption == "semester" ? price * 4 : price;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        initiatePayment(
          studentPhone,
          amountToPay,
          studentEmail!,
          studentName,
          houseName,
          location,
          landlordPhone,
          landlordId!,
          landlordName,
          houseId!,
          houseImage,
          paymentOption,
          lat,
          long,
        ).then((_) {
          Navigator.of(context).pop();

          setState(() => isBooking = false);
        });

        return AlertDialog(
          title: Text("Processing Payment"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text("Waiting for payment confirmation..."),
            ],
          ),
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    var screenWidth=MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => startBookHouse(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;

          return Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: width > 600 ? 600 : width * 0.95,
              ),
              child: Card(
                elevation: 4,
                margin: EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.house.containsKey("Images") &&
                          widget.house["Images"] is List)
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 200,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            autoPlay: true,
                          ),
                          items: widget.house["Images"].map<Widget>((imgUrl) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imgUrl,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 8),
                    screenWidth>700?
                      ListTile(
                        leading: Text(
                          "🏠 House Name -> ${widget.house["House Name"]}",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        trailing: Text(
                          "Price Ksh ${widget.house["House Price"]} per month",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ):
                    Text(
                      "🏠 House Name -> ${widget.house["House Name"]} \nPrice Ksh ${widget.house["House Price"]} per month",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                      Text("📍 ${widget.house["Location"] ?? ""}"),
                      Text("📏 ${widget.house["House Size"]}"),
                      Text("📝 ${widget.house["Description"]}"),
                      if (widget.house.containsKey("Available Amenities"))
                        Text(
                          "🔹 Amenities: ${widget.house["Available Amenities"]?.join(", ") ?? "N/A"}",
                        ),
                      const SizedBox(height: 10),
                      if (widget.house["isBooked"] == true)
                        ElevatedButton(
                          onPressed: () => cancelBooking(),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: Text("Cancel Booking"),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }



}
