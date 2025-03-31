
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/house_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../chartbot_fun/ai_funs.dart';
import '../../../constants.dart';
import '../../../data/chart_provider.dart';
import '../../../data/notifications.dart';
import '../../Components/SimpleAppBar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
  });


  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;


  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatService chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fs = FirebaseFirestore.instance;

  String paymentOP="";
  Map<String, dynamic> houseop={};

  bool nameAvailable=false;

bool awaitingPhoneNumberInput=false;
  var showHouses=false;

  String conversationStep = "select_option"; // Track user state: 'select_option' or 'enter_location'

  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;

  String? awaitingLocationInput; // To track if we're expecting a location input
   Map<String, dynamic> house={};



  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String welcomeMessage = await chatService.welcome();

      setState(() {
        messages.add({"role": "ai", "text": welcomeMessage});
      });
    });



  }



  void sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": userMessage});
      isTyping = true;
    });

    _controller.clear();


    if ( conversationStep == "enter_number") {
      if (await validatePhoneNumber(userMessage)) {
        await chatService.savePhoneNumber(userMessage);
        setState(() {
          messages.add({"role": "ai", "text": "Phone number saved successfully. Proceeding with booking..."});
          awaitingPhoneNumberInput = false;
          showHouses=true;
        });


        bookHouse(houseop, paymentOP);
      } else {
        setState(() {
          messages.add({"role": "ai", "text": "Invalid phone number. Please enter a valid 12-digit Kenyan number starting with 254."});
        });
      }
      return;
    }



    if (messages.isNotEmpty) {
      if (messages.any((map) =>
      map["text"]?.contains("Please enter your full name:") ?? false) &&
          !nameAvailable) {
        if (chatService.isValidFullName(userMessage)) {
          await chatService.saveName(userMessage);
          setState(() {
            messages.add({
              "role": "ai",
              "text":  "Welcome $userMessage! I am your assistant to help you find the house of your choice.\n\n"
                  "Here are the services we offer:\n"
                  "1️⃣ List all available houses in a specific location\n"
                  "2️⃣ See all locations with available houses\n\n"
                  "Which option would you like me to assist you with? (Reply with 1 or 2)"
            });
            isTyping=false;
          });
        } else {
          setState(() {
            messages.add({
              "role": "ai",
              "text": "Invalid name. Please enter your full name (e.g., Otike Mandevu)."
            });
            isTyping=false;
          });
        }
        return;
      }
    }







    String aiResponse = "";




     if (showHouses) {
      List<Map<String, dynamic>> houses = await chatService.getAllHouses();
      var selectedHouse = houses.firstWhere(
            (house) => house["House Name"].toLowerCase() == userMessage.toLowerCase(),
        orElse: () => {},
      );

      if (selectedHouse.isNotEmpty) {
        setState(() {
          house = selectedHouse;
        });




        aiResponse = "You have selected ${house['House Name']}. Proceeding to booking...";

          showBookingDialog(house);



        setState(() {
          conversationStep = "enter_number";

        });
       aiResponse="Please enter your phone number for payment (must start with 254).";


          setState(() {
          showHouses = false;
          isTyping=false;
        });


      } else {
        aiResponse = "Sorry, I couldn't find a house with that name. Please try again.";
      }
    }
    else if (conversationStep == "select_option") {

      aiResponse = await validateOption(userMessage);
      if (aiResponse.contains("Enter the Known Name of the location")) {
        setState(() {
          conversationStep = "enter_location";
        });
      }
    }
    else if (conversationStep == "enter_location") {
      bool isValid = await validateLocation(userMessage);

      if (isValid) {
        List<Map<String, dynamic>> houses = await chatService.getHousesByLocation(userMessage);

        if (houses.isNotEmpty) {
          aiResponse = "Click on a house or reply with the house name to proceed with booking.";

          for (var house in houses) {
            messages.add({
              "role": "ai",
              "text": "🏠 ${house["House Name"]} -> Booking",
              "house": house,
            });
          }

          setState(() {
            showHouses = true;
          });



        } else {
          aiResponse = "Sorry, no houses found in $userMessage ,Kindly enter another place so that i help you to find your dream house.";
          setState(() {
            conversationStep = "enter_location";
          });
        }

        conversationStep = "select_option";
      } else {
        aiResponse = "I couldn't find that location. Please enter a valid location.";
      }
    }



    setState(() {
      messages.add({"role": "ai", "text": aiResponse});
      isTyping = false;
    });

    Future.delayed(Duration(milliseconds: 300), _scrollToBottom);
  }






  void showBookingDialog(Map<String, dynamic> house) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Booking"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("You have selected ${house['House Name']} for booking."),
              SizedBox(height: 10),
              Text("Price: ${house['House Price']} Ksh"),
              SizedBox(height: 20),
              Text("Choose a payment plan:"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                print("month");
                bookHouse(house, "first_month");
                setState(() {
                  paymentOP="first_month";
                  houseop=house;
                });

                Navigator.pop(context);
              },
              child: Text("Pay for First Month"),
            ),
            TextButton(
              onPressed: () {
                bookHouse(house, "per_semester");
                print("per_semester");
                setState(() {
                  paymentOP="per_semester";
                  houseop=house;
                });
                Navigator.pop(context);
              },
              child: Text("Pay per Semester"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<void> bookHouse(Map<String, dynamic> house, String paymentOption) async {
    String houseId = house.containsKey("id") ? house["id"].toString() : "UNKNOWN_HOUSE_ID";
    String landlordId = house.containsKey("landlordId") ? house["landlordId"].toString() : "UNKNOWN_LANDLORD_ID";

    if (houseId == "UNKNOWN_HOUSE_ID" || landlordId == "UNKNOWN_LANDLORD_ID") {

      print("Full House Data: $house"); // wueh
      return;
    }

    String houseName = house["House Name"]?? "Unknown House";
    String location = house["Location"]?? "Unknown Location";
    double price = house["House Price"]?? 0.0;

    print("House ID: $houseId");
    print("Landlord ID: $landlordId");
    print("House Name: $houseName");
    print("Location: $location");
    print("Price: $price");

    String? studentEmail = auth.currentUser?.email;
    String? studentName =await chatService.getUserName();
    String? studentPhone = await chatService.getUserPhone();


    if (studentPhone == null || studentPhone.isEmpty) {
      setState(() {

        awaitingPhoneNumberInput = true;
      });
      return;
    }



    await fs.collection("applicants_details").doc(studentEmail).set(
      {"phone": studentPhone},
      SetOptions(merge: true),
    );




    print("Student Email: $studentEmail");
    print("Student Name: $studentName");
    print("Student Phone: $studentPhone");

    if (houseId == null || landlordId == null || studentEmail == null) {
      print("Error: Missing required data");
      return;
    }

    DocumentSnapshot landlordDoc = await fs.collection("Landlords").doc(landlordId).get();
    String landlordPhone = landlordDoc.exists ? landlordDoc.get("Phone Number") : "Unknown";
    String lname = landlordDoc.exists ? landlordDoc.get("Name") : "Unknown";



    print("Landlord Phone: $lname");
    print("Landlord Phone: $landlordPhone");




    double amountToPay = paymentOption == "per_semester" ? (price * 4 )/1000: price/8000;


    var response = await http.post(
      Uri.parse("https://mpesaapi.onrender.com/stkpush"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone": studentPhone,
        "amount": amountToPay,

      }),
    );

    if (response.statusCode !=null) {



      var callbackResponse = await http.get(Uri.parse("https://mpesaapi.onrender.com/callback"));

      if (callbackResponse.statusCode !=null) {
        Future.delayed(Duration(seconds: 5), () async {
       print("Wait for pay");


        await fs.collection("booked_students").doc(
            studentEmail).set({
          "email": studentEmail,
          "name": studentName ?? "Unknown",
          "stdContact": studentPhone,
          "houseName": houseName,
          "houseLocation": location,
          "payment_status": "Paid",
          "amount_paid": amountToPay,
          "landlordContact": landlordPhone,
          "landlord": lname,

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

        });

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
  }



  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(

      appBar:PreferredSize(
        preferredSize: Size.fromHeight(60),
        child:App_Bar(changeTheme: widget.changeTheme,
            changeColor: widget.changeColor,
            colorSelected: widget.colorSelected,

            title:"House Booking Assistant"),
      ),



      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [

                ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length + (isTyping ? 1 : 0),
                  itemBuilder: (context, index) {

                    if (isTyping && index == messages.length) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Typing...", style: TextStyle(
                            fontStyle: FontStyle.italic
                        )),
                      );
                    }
                    final message = messages[index];



                    if (message.containsKey("house") && message["house"] != null && showHouses) {
                      final house = message["house"];

                      if (house is Map<String, dynamic>) {

                   return HouseCard(house: house);

                      }
                    }


                    return Align(
                      alignment: message["role"] == "user" ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                          message["role"] == "user" ?
                                  isDark? Colors.blue:Colors.blue[200]
                              :
                          isDark? Colors.grey[900]:Colors.grey[300],


                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          message['text']??"",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(

                    controller: _controller,
                    textInputAction: TextInputAction.done,
                    keyboardType:conversationStep == "enter_number"?TextInputType.phone:TextInputType.text,
                    decoration: InputDecoration(
                      label:  Text(awaitingPhoneNumberInput?"Enter number to pay eg 254000000000":"Type a message..."),
                      hintText: awaitingPhoneNumberInput?"eg 254712845678":"Type a message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}


