
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/view_model.dart';
import 'package:flutter_frontend/View/Components/house_item.dart';
import 'package:flutter_frontend/data/payment.dart';
import 'package:flutter_frontend/data/wakeupapi.dart';
import 'package:flutter_frontend/pages/rate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../chartbot_fun/ai_funs.dart';
import '../../../constants.dart';
import '../../../data/chart_provider.dart';
import '../../../data/notifications.dart';
import '../../../data/providers.dart';
import '../../../pages/booked.dart';
import '../../../pages/help.dart';
import '../../../pages/searched_places.dart';
import '../../Components/SimpleAppBar.dart';
import 'animateTyping.dart';
import 'chart_app_bar.dart';
import 'mapit.dart';

class ChatScreen extends ConsumerStatefulWidget {
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
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatService chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fs = FirebaseFirestore.instance;

  String onTapedScreen='ai';

  bool showMap=false;
  bool showAllHouse=false;
  String pkey="pageKey";

  String selectedSpecType = "";
  bool awaitingSpecSelection = false;
  bool awaitingSpecValue = false;


  String paymentOP="";
  Map<String, dynamic> houseop={};



  bool awaitingPhoneNumberInput=false;
  var showHouses=false;


  String conversationStep="select_option";

  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;

  String? awaitingLocationInput;
  Map<String, dynamic> house={};

  String validphn='';




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

    WakeUpServer();

  }



  void sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;


    if (chatService.userWantsToGoBack(userMessage)) {
      setState(() {
        conversationStep = "select_option";
        showHouses = false;
        awaitingPhoneNumberInput = false;
        showMap = false;
        _controller.clear();

        messages.add({
          "role": "ai",
          "text": "You're back at the main service list. Here are the services we offer:\n\n"
              " 1 List all available houses in a specific location\n"
              " 2 See all locations with available houses\n"
              " 3 Report for an emergency\n"
              " 4 Search for available  houses by specifications\n"
              " 5 See all vacant houses\n\n"
              "Which option would you like me to assist you with?"
        });
        isTyping = false;
      });
      Future.delayed(Duration(milliseconds: 300), _scrollToBottom);

      return;
    }



    setState(() {
      messages.add({"role": "user", "text": userMessage});
      isTyping = true;
    });

    _controller.clear();





    if ( conversationStep == "enter_number") {


      if (await validatePhoneNumber(userMessage)) {

           await chatService.savePhoneNumber(userMessage);
           validphn=userMessage;


        setState(() {
          messages.add({"role": "ai", "text": "Phone number saved successfully. Proceeding with booking..."});

          awaitingPhoneNumberInput = false;
          isTyping=false;
          showHouses=false;

        });


        bookHouse(houseop, paymentOP);





      } else {
        setState(() {
          messages.add({"role": "ai", "text": "Invalid phone number. Please enter a valid 12-digit Kenyan number starting with 254."});
        });
      }
      return;
    }


    String name= await chatService.getUserName();
    var nameAvailable= name=="user";
    print(name);
    if (nameAvailable) {
      print(name);
      if ( messages.any((map) =>
      map["text"]?.contains("Please enter your full name:") ?? false) ) {

        if (await validateFullName(userMessage)) {
          await chatService.saveName(userMessage);

          setState(() {
            messages.add({
              "role": "ai",
              "text": "Welcome ${userMessage.trim().split(" ").first}, I am your assistant to help you find the house of your choice.\n\n"
                  "Here are the services we offer:\n"
                  " 1 List all available houses in a specific location\n"
                  " 2 See all locations with available houses\n"
                  " 3 Report for an emergency\n"
                  " 4 Search for available  houses by specifications\n"
                  " 5 See all vacant houses\n\n"
                  "Which option would you like me to assist you with? (Reply with one of the above options eg 1 or option 1)"
            });
            isTyping = false;




          });
        } else {
          print(name);
          setState(() {
            messages.add({
              "role": "ai",
              "text": "Invalid name. Please enter your full name (e.g., Otike Mandevu)."
            });
            isTyping = false;
          });
        }


        return;
      }


    }

    String aiResponse = "";

    if (showHouses) {

      ref.watch(isBooked)?
          setState(() {

          }):null;

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
      }else if(aiResponse.contains("Viewing all locations with available houses.")) {



        conversationStep = "view_locations";

        setState(() {
          showMap=true;
        });

        if(conversationStep == "view_locations") {
          aiResponse = await chatService.handleOption2();
          //  Future.delayed(Duration(seconds: 1), () async {
          setState(() {

            messages.add({
              "role": "ai",
              "text": aiResponse
            });
            conversationStep = "enter_location";
          });
          // });
        }


      }else if(aiResponse.contains("Report for an emergency.")) {

        aiResponse="Sorry Please, The service will be implemented soon, Kindly type go back to go to the main menu.";



      }else if(aiResponse.contains("houses by specifications")) {

        setState(() {
          conversationStep = "specification_selection";
          awaitingSpecSelection = true;
          messages.add({
            "role": "ai",
            "text": "Please choose how you'd like to search:\n1. By Price\n2. By Amenities\n3. By Description\n(Type 1, 2, or 3)",
          });
          isTyping=false;
        });
        Future.delayed(Duration(milliseconds: 300), _scrollToBottom);

        return;



      }else if(aiResponse.contains( "See all vacant houses")) {

        List<Map<String, dynamic>> houses = await chatService.getHouses();

        if (houses.isNotEmpty) {
          aiResponse = "Click on a house or reply with the house name to proceed with booking.";

       // for (var house in houses) {
            messages.add({
              "role": "ai",
              "text": "🏠",
            "house": houses,
            });
        // }

          isTyping=false;
          setState(() {
            showHouses=true;


          });



        } else {
          aiResponse = "Thousand apologies, currently there is no available house,I will notify you when they are available.";
          setState(() {
           userMessage='go back';
          });


        }

      }


    }else if (conversationStep == "specification_selection" && awaitingSpecSelection) {
      if (userMessage == "1") {
        setState(() {
          selectedSpecType = "price";
          awaitingSpecSelection = false;
          awaitingSpecValue = true;
          conversationStep = "enter_spec_value";
          messages.add({"role": "ai", "text": "Please enter the price range or max price. (e.g., 3000-6000 or just 5000)"});
        });
      } else if (userMessage == "2") {
        setState(() {
        selectedSpecType = "amenities";
        awaitingSpecSelection = false;
        awaitingSpecValue = true;
        conversationStep = "enter_spec_value";
        messages.add({"role": "ai", "text": "Please enter the amenity you're looking for (e.g., WiFi,GYM, parking):"});
      });
      } else if (userMessage == "3") {
        setState(() {
        selectedSpecType = "description";
        awaitingSpecSelection = false;
        awaitingSpecValue = true;
        conversationStep = "enter_spec_value";
        messages.add({"role": "ai", "text": "Please enter a keyword related to the house description (e.g., quiet, spacious, furnished):"});
        });
      } else {
        setState(() {
        messages.add({"role": "ai", "text": "Invalid choice. Please reply with 1, 2, or 3."});
      });
      }
      Future.delayed(Duration(milliseconds: 300), _scrollToBottom);
      isTyping=false;

      return;
    }else if (conversationStep == "enter_spec_value" && awaitingSpecValue) {
      List<Map<String, dynamic>> results = [];

      if (selectedSpecType == "price") {
        int? minPrice, maxPrice;
        if (userMessage.contains("-")) {
          var parts = userMessage.split("-");
          minPrice = int.tryParse(parts[0].trim());
          maxPrice = int.tryParse(parts[1].trim());
        } else {
          maxPrice = int.tryParse(userMessage.trim());
          minPrice = 0;
        }

        if (maxPrice != null) {
          results = await chatService.getHousesByPriceRange(minPrice!, maxPrice);
        }
      } else if (selectedSpecType == "amenities") {

        results = await chatService.getHousesByAmenity(userMessage.trim());
        print("user =$results");
      } else if (selectedSpecType == "description") {

        results = await chatService.getHousesByDescription(userMessage.trim());


      }

      if (results.isEmpty) {
        print("i am result $results");
        messages.add({"role": "ai", "text": "No houses found matching your criteria. Would you like to try again? Type 'go back' to return."});

      } else {
        messages.add({"role": "ai", "text": "Here are some houses matching your criteria:\n\nClick on a house or reply with its name to book."});
        // for (var house in results) {
          messages.add({
            "role": "ai",
            "text": "🏠",
           "house": results,
          });
        // }
        setState(() {
          showHouses = true;
          awaitingSpecValue = false;
          conversationStep = "select_house_from_spec";
        });
      }
      return;
    }


    else if (conversationStep == "enter_location") {
      setState(() {
        showMap=false;
      });

     // bool isValid = await validateLocation(userMessage);

      if (chatService.isLegitPlace(userMessage.trim())) {
        onSearch(userMessage.trim(),  ref) ;


        List<Map<String, dynamic>> houses = await chatService.getHousesByLocation(userMessage);

        if (houses.isNotEmpty) {
          aiResponse = "Click on a house or reply with the house name to proceed with booking.";

          // for (var house in houses) {
            messages.add({
              "role": "ai",
              "text": "🏠",
            "house": houses,
            });
          // }

          setState(() {
            showHouses = true;
          });



        }else {
          setState(() {
            conversationStep = "enter_location";
          });
          aiResponse = "Sorry, no houses found in $userMessage ,Kindly enter another place so that i help you to find your dream house.";

        }




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
    double lat = house["Live Latitude"]?? 0.0;
    double long = house["Live Longitude"]?? 0.0;
    // List<String> houseImages=house["Images"]??[];
    List<String> houseImages = house["Images"].cast<String>()??[];
    print("House ID: $houseId");
    print("Landlord ID: $landlordId");
    print("House Name: $houseName");
    print("Location: $location");
    print("Price: $price");
    print("images: $houseImages");

    String? studentEmail = auth.currentUser?.email;
    String? studentName =await chatService.getUserName();


    String? studentPhone = validphn;



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




    double amountToPay = paymentOption == "per_semester" ? (price * 4 ): price;


    initiatePayment(studentPhone, amountToPay,
        studentEmail, studentName, houseName, location,
        landlordPhone, landlordId, lname, houseId,
        houseImages, paymentOption,lat,long,context,ref)
        .then((_){
      if(ref.watch(isBooked)){
        // setState(() {
          showHouses=false;
          messages.add({"role": "ai", "text": "Congratulation for successfully booking the house ,you can see it in Booked house. type go back to access other services."});

        // });
      }
    });


  }







  @override
  Widget build(BuildContext context) {
    var screenWidth=MediaQuery.of(context).size.width;
    final prefs = ref.watch(sharedPreferencesProvider);


    return Scaffold(

        appBar:


        PreferredSize(
          preferredSize: Size.fromHeight(60),
          child:

          Chat_Bar(changeTheme: widget.changeTheme,
              changeColor: widget.changeColor,
              colorSelected: widget.colorSelected,

              title:"House Booking Assistant"),
        ),



        body:ref.watch(toggleMenu)?
        Column(
          children: [
        Expanded(
            child:
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Colors.grey,
                        width: 3.0,
                      ),
                    ),
                  ),
                  width:180 ,
                  // height: double.infinity,
                  child: Column(
                      spacing: 5,
                      children: [
                        SizedBox(height: 5),
                        ListTile(
                          leading: Icon(Icons.mark_unread_chat_alt_outlined),

                          title:Text("Services"),
                          onTap: (){
                            setState(()  {
                              onTapedScreen='ai';
                              prefs.setString(pkey, "ai");

                            });
                          },
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.house_outlined),

                          title:Text("Booked House"),
                          onTap: (){
                            setState(() {
                              onTapedScreen='booked';
                              prefs.setString(pkey, "booked");
                            });
                          },
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.place_outlined),
                          title:Text("Searched places"),
                          onTap: (){
                            setState(() {
                              onTapedScreen='places';
                              prefs.setString(pkey, "places");
                            });
                          },
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.assistant_photo_outlined),
                          title:Text("Help and Manual"),
                          onTap: (){
                            setState(() {
                              onTapedScreen='help';
                              prefs.setString(pkey, "help");
                            });
                          },
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.star),
                          title:Text("Rate us"),
                          onTap: (){
                            setState(() {
                              onTapedScreen='rate';
                              prefs.setString(pkey, "rate");
                            });
                          },
                        ),
                        Divider(),





                      ] ),

                ),
                Expanded(
                    child: prefs.getString(pkey)=="ai"?AiPage():
                    prefs.getString(pkey)=="booked"?BookedHousesScreen():
                    prefs.getString(pkey)=="places"?SearchedPlacesScreen():
                    prefs.getString(pkey)=="help"?HelpAndManualPage():
                    prefs.getString(pkey)=="rate"?RateUsPage():
                    AiPage()


                ),

              ],
            )
        )])

        :
        prefs.getString(pkey)=="ai"?AiPage():
        prefs.getString(pkey)=="booked"?BookedHousesScreen():
        prefs.getString(pkey)=="places"?SearchedPlacesScreen():
        prefs.getString(pkey)=="help"?HelpAndManualPage():
        prefs.getString(pkey)=="rate"?RateUsPage():
        AiPage()




    );
  }

  Widget AiPage() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    var screenWidth=MediaQuery.of(context).size.width;
    var screenHeight=MediaQuery.of(context).size.width;
    int crossAxisCount;
    if (screenWidth < 300) {
      crossAxisCount = 1;
    } else if (screenWidth < 700) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }

    return Column(
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
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TypingIndicator(),
                        ],
                      ),

                    );


                  }

                  final message = messages[index];


                  if (showMap && index == messages.length - 1) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Here are all available locations:",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: screenWidth * 0.7,
                              height: screenHeight * 0.5,
                              child: MapScreen(
                                  locations: chatService.getAllLocations()),
                            ),
                          ],
                        ),
                      ),
                    );
                  }



                  if (message.containsKey("house") && message["house"] != null && showHouses) {
                    final houses = message["house"];
                    print("I am house $houses");

                    if (houses is List) {
                      final List<Map<String, dynamic>> houseList = houses.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          childAspectRatio: 0.75,
                          children: houseList.map<Widget>((house) {
                            return HouseCard(house: house);
                          }).toList(),
                        ),
                      );
                    }
                    else  {

                      return HouseCard(house: house);
                    }
                  }


                  return Align(
                    alignment: message["role"] == "user" ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: message["role"] == "user"
                            ? isDark ? Colors.blue : Colors.blue[200]
                            : isDark ? Colors.grey[900] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        message['text'] ?? "",
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
                  keyboardType: conversationStep == "enter_number" ? TextInputType.phone : TextInputType.text,
                  decoration: InputDecoration(
                    label: Text(awaitingPhoneNumberInput ? "Enter number to pay e.g. 254000000000" : "Type a message..."),
                    hintText: awaitingPhoneNumberInput ? "e.g. 254712845678" : "Type a message...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onSubmitted: (value) {
                    sendMessage();
                  },
                ),
              ),

              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.send, color: Colors.blue,size: 24,),
                onPressed: sendMessage,
              )
            ],
          ),
        )
      ],
    );
  }





}



