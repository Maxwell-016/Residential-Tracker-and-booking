

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

    if (studentPhone == null || studentPhone!.isEmpty) {
      await _promptForPhoneNumber();
      // if (studentPhone == null || studentPhone!.isEmpty) {
      //   print("Phone number not provided.");
      //   setState(() => isBooking = false);
      //   return;
      // }
    }

    _showPaymentOptions();
    setState(() => isBooking = false);
  }

  Future<void> _promptForPhoneNumber() async {
    String? phoneNumber = await showDialog<String>(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text("Enter Your Phone Number"),
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
              child: Text("Save"),
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
    double housePrice = widget.house["House Price"]/1000 ?? 0.0;
    double monthlyPayment = housePrice;
    double semesterPayment = (housePrice * 4)/4000;

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
                    _processBooking(value);  // Run after closing dialog
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
                    _processBooking(value);  // Run after closing dialog
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
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
      await FirebaseFirestore.instance
          .collection("Landlords")
          .doc(landlordId)
          .collection("Houses")
          .doc(houseId)
          .update({"isBooked": true});

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
    String location = widget.house["Location"] ?? "Unknown Location";
    double price = widget.house["House Price"] ?? 0.0;
    List<String> houseImage = widget.house["Images"] ?? [];


    if (landlordId == null || houseId == null) {
      print("Error: LandlordId or HouseId is null");
      setState(() => isBooking = false);
      return;
    }

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

    // Fetch landlord details
    DocumentSnapshot landlordDoc = await fs.collection("Landlords").doc(landlordId).get();
    String landlordPhone = landlordDoc.exists ? landlordDoc.get("Phone Number") : "Unknown";
    String landlordName = landlordDoc.exists ? landlordDoc.get("Name") : "Unknown";

    double amountToPay = paymentOption == "semester" ? price * 4 : price;

    var response = await http.post(
      Uri.parse("https://mpesaapi.onrender.com/stkpush"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": studentPhone, "amount": amountToPay}),
    );

    if (response.statusCode != null) {

      var callbackResponse = await http.get(Uri.parse("https://mpesaapi.onrender.com/callback"));

      if (callbackResponse.statusCode !=null) {
        print("Payment successful, proceeding with booking...");

        await fs.collection("booked_students").doc().set({
          "email": studentEmail,
          "name": studentName ?? "Unknown",
          "stdContact": studentPhone,
          "houseName": houseName,
          "houseLocation": location,
          "payment_status": "Paid",
          "amount_paid": amountToPay,
          "landlordContact": landlordPhone,
          "landlordId":landlordId,
          "landlord": landlordName,
          "images":houseImage
        });

        await fs
            .collection("Landlords")
            .doc(landlordId)
            .collection("Houses")
            .doc(houseId)
            .update({"isBooked": true});


        String msg="$houseName has been booked successfully with the '$paymentOption' option!";
        print(msg  );
        trigernotification(null, msg, "House Booked Successfully");

      } else {
        String msg="Booking not completed.";
        print(msg);
        trigernotification(null, msg, "Payment failed!!");

      }
    } else {

      String msg="Error: M-Pesa request failed.";
      print(msg);
      trigernotification(null, msg, "Payment failed!!");

    }

    setState(() => isBooking = false);

  }







  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => startBookHouse(),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width > 600
                ? 600
                : MediaQuery.of(context).size.width * 0.9,
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
                  if (widget.house.containsKey("Images") && widget.house["Images"] is List)
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        itemCount: widget.house["Images"].length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.house["Images"][index],
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),

                  SizedBox(height: 8),
                  ListTile(
                    leading: Text(
                      "🏠 ${"House Name -> "+widget.house["House Name"]} ",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    trailing: Text(
                      "Price Ksh ${widget.house["House Price"]} per month",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Text("📍 ${widget.house["Location"]}" ?? ""),
                  Text("📏 ${widget.house["House Size"]}"),
                  Text("📝 ${widget.house["Description"]}"),
                  if (widget.house.containsKey("Available Amenities"))
                    Text("🔹 Amenities: ${widget.house["Available Amenities"]?.join(", ") ?? "N/A"}"),
                  SizedBox(height: 10),
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
      ),
    );
  }
}

