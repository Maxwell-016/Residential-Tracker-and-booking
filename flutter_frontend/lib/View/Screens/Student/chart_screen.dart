
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/house_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../chartbot_fun/ai_funs.dart';
import '../../../constants.dart';
import '../../../data/chart_provider.dart';
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

  String paymentOP="";
  Map<String, dynamic> houseop={};

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
    _initializeChat();
  }

  void _initializeChat() async {
    String userName = await chatService.getUserName();
    setState(() {
      messages.add({
        "role": "ai",
        "text": "Welcome $userName! I am your assistant to help you find the house of your choice.\n\n"
            "Here are the services we offer:\n"
            "1️⃣ List all available houses in a specific location\n"
            "2️⃣ See all locations with available houses\n\n"
            "Which option would you like me to assist you with? (Reply with 1 or 2)"
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
    String aiResponse = "";

    // Check if user typed a house name
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

        // Proceed with booking logic
        aiResponse = "You have selected ${house['House Name']}. Proceeding to booking...";
          showBookingDialog(house);



        //   setState(() {
        //   showHouses = true;
        // });

        if(paymentOP!="") {
          aiResponse = "You want to pay for $paymentOP";
        }

      } else {
        aiResponse = "Sorry, I couldn't find a house with that name. Please try again.";
      }
    }
    else if (conversationStep == "select_option") {
      // Normal flow: Validate user's choice (Option 1 or 2)
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
              "text": "🏠 ${house["House Name"]} - ${house["House Price"]} Ksh\n📍 ${house["location"]}",
              "house": house,
            });
          }

          setState(() {
            showHouses = true;
          });



        } else {
          aiResponse = "Sorry, no houses found in $userMessage.";
        }

        conversationStep = "select_option"; // Reset state
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



//   void sendMessage() async {
//     String userMessage = _controller.text.trim();
//     if (userMessage.isEmpty) return;
//
//     setState(() {
//       messages.add({"role": "user", "text": userMessage});
//       isTyping = true;
//     });
//
//     _controller.clear();
//     String aiResponse="";
//
//
//     if (conversationStep == "select_option") {
//       // 🔹 Step 1: Validate user's choice (Option 1 or Option 2)
//       aiResponse = await validateOption(userMessage);
//
//       if (aiResponse.contains("Enter the Known Name of the location")) {
//
//         setState(() {
//           conversationStep = "enter_location";
//         });
//
//       }
//
//     } else if (conversationStep == "enter_location") {
//
//       bool isValid = await validateLocation(userMessage);
//
//
//       if (isValid) {
//         List<Map<String, dynamic>> houses = await chatService.getHousesByLocation(userMessage);
//
//         if (houses.isNotEmpty) {
//           aiResponse = "Click on the house that you will like me to help you in booking or reply with house name.";
//
// print(houses.length);
//           for (var house in houses) {
//
//
//             messages.add({
//               "role": "ai",
//              "text": "🏠 ${house["House Name"]} - ${house["House Price"]} Ksh\n📍 ${house["location"]}",
//               "house": house,
//             });
//
//
//           }
//
//           // aiResponse = "Here are the available houses in $userMessage:\n";
//           // for (var house in houses) {
//           //
//           //   aiResponse += "🏠 ${house["House Name"]} - ${house["House Price"]} - ${house["Description"]}\n";
//           // }
//           //
//           setState(() {
//             showHouses=true;
//           });
//
//
//         } else {
//           aiResponse = "Sorry, no houses found in $userMessage.";
//         }
//
//         conversationStep = "select_option"; // ✅ Reset after fetching results
//       } else {
//         aiResponse = "I couldn't find that location. Please enter a valid location.";
//       }
//     }
//
//     setState(() {
//       messages.add({"role": "ai", "text": aiResponse });
//       isTyping = false;
//     });
//
//     Future.delayed(Duration(milliseconds: 300), _scrollToBottom);
//   }


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

  Future<String> bookHouse(Map<String, dynamic> house, String paymentOption) async {
    String houseId = house["id"];
    String landlordId = house["landlordId"];

    if (houseId == null || landlordId == null) {
      print("Error: HouseId or LandlordId is null");
      return "";
    }

    // Update Firestore to mark house as booked
    await chatService.bookHouse(houseId, landlordId, paymentOption);


      return "${house['House Name']} has been booked successfully with the '$paymentOption' option!";

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

                    // if (message.containsKey("house") && message["house"] != null  && showHouses) {
                    //   final house = message["house"];
                    //
                    //
                    //   if (house is Map<String, dynamic>) {
                    //
                    //   print(house["Images"]);
                    //
                    //     return Card(
                    //       child:Padding(
                    //         padding: EdgeInsets.all(8),
                    //
                    //           child: Column(
                    //
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //
                    //         if (house.containsKey("Images"))
                    //           Image.network(house["Images"], width: 250, height: 200, fit: BoxFit.cover),
                    //         SizedBox(height: 5),
                    //         Text("🏠 ${house["House Name"]} - ${house["House Price"]} Ksh", style: TextStyle(fontWeight: FontWeight.bold)),
                    //         Text("📍 ${house["location"]}"),
                    //         Text("📏 ${house["House Size"]}"),
                    //         Text("📝 ${house["Description"]}"),
                    //         if (house.containsKey("Available Amenities"))
                    //           Text("🔹 Amenities: ${house["Available Amenities"]?.join(", ") ?? "N/A"}"),
                    //
                    //       ],
                    //     )
                    //     )
                    //
                    //     );
                    //
                    //   } else if (house is String) {
                    //
                    //
                    //    print(house);
                    //   }
                    // }


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
                    decoration: InputDecoration(
                      hintText: "Type a message...",
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





// import 'package:flutter/material.dart';
//
// import '../../../data/chart_provider.dart';
//
// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final ChatService chatService = ChatService();
//   final ScrollController _scrollController = ScrollController();
//
//   final nameAvailable=false;
//
//   List<Map<String, String>> messages = [];
//   bool isTyping = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       String welcomeMessage = await chatService.welcome();
//       setState(() {
//         messages.add({"role": "ai", "text": welcomeMessage});
//       });
//     });
//   }
//
//   void _scrollToBottom() {
//     _scrollController.animateTo(
//       _scrollController.position.maxScrollExtent,
//       duration: Duration(milliseconds: 500),
//       curve: Curves.easeInOut,
//     );
//   }
//
//   void sendMessage() async {
//     String userMessage = _controller.text.trim();
//     if (userMessage.isEmpty) return;
//
//     setState(() {
//       messages.add({"role": "user", "text": userMessage});
//       isTyping = true;
//     });
//
//     _controller.clear();
//
//
//     if (messages.isNotEmpty) {
//       if (messages.any((map) =>
//       map["text"]?.contains("Please enter your full name:") ?? false) &&
//           !nameAvailable) {
//         if (chatService.isValidFullName(userMessage)) {
//           await chatService.saveName(userMessage);
//           setState(() {
//             messages.add({
//               "role": "ai",
//               "text": "Thank you, $userMessage! Would you like to see areas with available houses, or search for a specific area?"
//             });
//           });
//         } else {
//           setState(() {
//             messages.add({
//               "role": "ai",
//               "text": "Invalid name. Please enter your full name (e.g., John Doe)."
//             });
//           });
//         }
//         return;
//       }
//
//
//       // ✅ Detect user's intent (Search or See Available Houses)
//       String aiResponse = await chatService.detectIntent(userMessage);
//
//       if (aiResponse == "see_available_houses") {
//         // Show available houses
//         List<String> houses = await chatService.getAvailableHouses();
//         setState(() {
//           messages.add({
//             "role": "ai",
//             "text": "Here are the areas with available houses:\n${houses.join(
//                 ", ")}\nWould you like to book one?"
//           });
//         });
//       } else if (aiResponse == "search_specific_area") {
//         setState(() {
//           messages.add({
//             "role": "ai",
//             "text": "Please enter the area you want to search for houses."
//           });
//         });
//       } else if (aiResponse.startsWith("search_area:")) {
//         // Extract area from AI response
//         String area = aiResponse.split(":")[1];
//         List<String> houses = await chatService.getHousesInArea(area);
//
//         if (houses.isEmpty) {
//           setState(() {
//             messages.add({
//               "role": "ai",
//               "text": "Sorry, no houses found in $area. Try another area?"
//             });
//           });
//         } else {
//           setState(() {
//             messages.add({
//               "role": "ai",
//               "text": "Here are the available houses in $area:\n${houses.join(
//                   ", ")}\nWould you like to book one?"
//             });
//           });
//         }
//       } else {
//         setState(() {
//           messages.add({
//             "role": "ai",
//             "text": "I'm sorry, I didn't understand. Can you please clarify?"
//           });
//         });
//       }
//
//       isTyping = false;
//       Future.delayed(Duration(milliseconds: 300), _scrollToBottom);
//     }
//   }
//
//  @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("House Booking & Help Assistant")),
//       body: Column(
//         children: [
//           Expanded(
//             child: Stack(
//               children: [
//                 ListView.builder(
//                   controller: _scrollController,
//                   itemCount: messages.length + (isTyping ? 1 : 0),
//                   itemBuilder: (context, index) {
//                     if (isTyping && index == messages.length) {
//                       return Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text("Typing...", style: TextStyle(fontStyle: FontStyle.italic)),
//                       );
//                     }
//                     final message = messages[index];
//                     return Align(
//                       alignment: message["role"] == "user"
//                           ? Alignment.centerRight
//                           : Alignment.centerLeft,
//                       child: Container(
//                         margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                         padding: EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: message["role"] == "user" ? Colors.blue[200] : Colors.grey[300],
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         child: Text(
//                           message['text']!,
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 Positioned(
//                   bottom: 10,
//                   right: 10,
//                   child: FloatingActionButton(
//                     mini: true,
//                     onPressed: _scrollToBottom,
//                     child: Icon(Icons.arrow_downward),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText: "Type a message...",
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 IconButton(
//                   icon: Icon(Icons.send, color: Colors.blue),
//                   onPressed: sendMessage,
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
