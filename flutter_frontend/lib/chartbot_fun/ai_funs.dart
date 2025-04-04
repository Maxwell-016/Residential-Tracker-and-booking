import 'dart:convert';

import 'package:flutter_frontend/data/binarySeachLocation.dart';

import '../data/chart_provider.dart';
import '../data/codinates.dart';

AIService aiService = AIService();

final ChatService chatService = ChatService();

Future<String> validateOption(String userMessage) async {
  String response = await aiService.getAIResponse(
      "Classify this response: '$userMessage'. Possible outputs: option_1, option_2,option_3, option_4, option_5, invalid. "
      "If the user intends to select option 1, return 'option_1'. "
      "If the user intends to select option 2, return 'option_2'. "
      "If the user intends to select option 3, return 'option_3'. "
      "If the user intends to select option 4, return 'option_4'. "
      "If the user intends to select option 5, return 'option_5'. "
      "If the response is completely unrelated, return  'invalid'. "
      "if the user tries or intents to answer by the content of the question  which are"
      "Here are the services we offer:\n"
      " 1 List all available houses in a specific location\n"
      " 2 See all locations with available houses\n"
      " 3 Report for an emergency\n"
      " 4 Ask for help and related questions\n"
      " 5 Send feedback to the landlord\n\n"
      "Which option would you like me to assist you with? "
      "  also return the correct option "
      "Do NOT return any extra text or explanation.");

  print(response);

  if (response.trim() == "option_1") {
    return "Enter the Known Name of the location or place you want to see the available houses in:";
  } else if (response.trim() == "option_2") {
    return "Viewing all locations with available houses.";
  } else if (response.trim() == "option_3") {
    return "Report for an emergency.";
  } else if (response.trim() == "option_4") {
    return "Ask for help and related questions.";
  } else if (response.trim() == "option_5") {
    return "Send feedback to the landlord";
  } else {
    return "I didn't understand your choice. Please reply with a value 1 to 5 or correct option";
  }
}

Future<bool> validateLocation(String location) async {
  String response = await aiService.getAIResponse(


  return response.trim().toLowerCase() == "yes";
}

Future<bool> validatePhoneNumber(String phn) async {
  String response = await aiService.getAIResponse(
      "Is '$phn' a valid kenyan number? having 12 digits,and starting with 254 .Reply only with 'yes' or 'no'.");

  return response.trim().toLowerCase() == "yes";
}

Future<bool> validateFullName(String fullName) async {
  String response = await aiService.getAIResponse(
      "Is '$fullName' a valid human name? The name should consist of two meaningful words that resemble real names, and it should not be random characters, offensive words, or nonsense. Reply only with 'yes' or 'no'.");

  return response.trim().toLowerCase() == "yes";
}

bool isValidKenyanPhoneNumber(String phoneNumber) {
  return RegExp(r'^254\d{9}$').hasMatch(phoneNumber);
}


    //  var houses=await chatService.getHousesByLocation(location);
    // print(houses);

    // locat["vacant"]=houses.length;
    locat["vacant"] = 1;

    print(locat);
    return locat;
  } catch (e) {
    print("Error parsing AI response: $e");
    return {};
  }
}

Future<List<Map<String, dynamic>>> getLocationsToBeMarked() async {
  List<Map<String, dynamic>> locateit = [];
  List<String> locations = ["Masinde Muliro University"];



  for (var location in locations) {
    var codAi = await getLocationDetails(location);
    print("am searchin$location");
    var markCode = realIsFound(realcode, location.toLowerCase());

    print("binary $markCode");
    if (markCode != null) {
      codAi["lat"] = markCode.latitude;
      codAi["lng"] = markCode.longitude;
    }

    print("codeai $codAi");

    locateit.add(codAi);
  }

  print("I am locate it $locateit");

  // [{id: Masinde Muliro University, name: Masinde Muliro University of Science and Technology, address: Kakamega-Webuye Rd, Kakamega, Kenya, lat: 0.28979, lng: 34.75052, region: Kakamega, Western Kenya, image: https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/MMUST_Administration_Block.jpg/1280px-MMUST_Administration_Block.jpg, vacant: 1},
  // {id: lurambi, name: Lurambi, address: Lurambi, Kakamega County, Kenya, lat: 0.2825, lng: 34.75361, region: Kakamega County, image: https://example.com/lurambi.jpg, vacant: 1}]

  return locateit;
}
