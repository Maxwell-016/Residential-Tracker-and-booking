import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/snackbars.dart';
// import 'package:flutter_frontend/data/payment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../chartbot_fun/ai_funs.dart';
import '../../data/chart_provider.dart';
import '../../data/notifications.dart';
import '../../data/payment.dart';
import '../../data/providers.dart';

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

    await _promptForPhoneNumber();
    _showPaymentOptions();
    setState(() => isBooking = false);
  }
  TextEditingController controller = TextEditingController();


  Future<void> _promptForPhoneNumber() async {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


    String? phoneNumber = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Phone Number For Payment"),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  hintText: "e.g., 0712345678",
                border: OutlineInputBorder()

              ),
              validator: (value) {
                String? formatted = validateAndFormatKenyanPhone(value ?? '');
                if (formatted == null) {
                  return "Enter a valid Kenyan phone number";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  String input = controller.text.trim();
                  print("Input number: $input");
                  String? formatted = validateAndFormatKenyanPhone(input);
                  print("Formatted number: $formatted");
                  Navigator.pop(context, formatted);
                }
              },
              child: Text("Send"),
            ),
          ],
        );
      },
    );

    if (phoneNumber != null) {
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
        ref.read(isBooked.notifier).state = false;
      });
trigernotification(context,  "Booking canceled successfully.","Booking");
      print("Booking canceled successfully.");
    } catch (e) {
      trigernotification(context,  "Error canceling booking: $e","Booking");
      print("Error canceling booking: $e");

    }

    setState(() => isBooking = false);
    return;
  }

  Future<void> _showPaymentOptions() async {
    String? studentPhone = await chatService.getUserPhone();




    double housePrice = widget.house["House Price"] ?? 0.0;
    double monthlyPayment = housePrice;
    double semesterPayment = housePrice * 4;


    if (controller.text.isEmpty) {
      SnackBars.showErrorSnackBar(context, "Phone number for payment not provided.Booking cancelled");
      if (studentPhone == null || studentPhone.isEmpty) {
        print("Phone number not provided.");
        setState(() => isBooking = false);
        return;
      }
    }else {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text("Select Payment Option"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                        "Pay for the first month - Ksh $monthlyPayment"),
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
  }

  Future<void> markHouseAsBooked(String landlordId, String houseId) async {
    await FirebaseFirestore.instance
        .collection("Landlords")
        .doc(landlordId)
        .collection("Houses")
        .doc(houseId)
        .update({"isBooked": true});
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
      if (studentPhone == null || studentPhone.isEmpty) {
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
          context,
            ref
        ).then((_) {

          setState(() {
            widget.house["isBooked"] = ref.watch(isBooked);
          //  ref.read(isBooked.notifier).state = true;
          });

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
    var screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => startBookHouse(),

      child: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;

          double carouselWidth = constraints.maxWidth;
          double aspectRatioHeight = carouselWidth * 9 / 16; // 16:9 ratio


          return
            // Center(

            // child:
            Container(
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
                            // height: 200,
                            height: aspectRatioHeight,
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
                                // height: 200,
                                height: aspectRatioHeight,
                                fit: BoxFit.cover,
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 8),
                      // screenWidth > 700
                      //     ? ListTile(
                      //   leading: Text(
                      //     "🏠 House Name -> ${widget.house["House Name"]}",
                      //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      //   ),
                      //   trailing: Text(
                      //     "Price Ksh ${widget.house["House Price"]} per month",
                      //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      //   ),
                      // )
                      //     :
                      Text(
                        "🏠 House Name -> ${widget.house["House Name"]} \nPrice Ksh ${widget.house["House Price"]} per month",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text("📍 ${widget.house["Location"] ?? ""}"),
                      Text("📏 ${widget.house["House Size"]}"),
                      Text("📝 ${widget.house["Description"]}",overflow: TextOverflow.ellipsis,),
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
            );
          // ,


          // );


        },
      ),
    );
  }
}
