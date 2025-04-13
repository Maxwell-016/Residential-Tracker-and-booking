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
          " 4 Search for available  houses by specifications\n"
          " 5 See all vacant houses\n\n"
          "Which option would you like me to assist you with? "
          "  also return the correct option "
          "Do NOT return any extra text or explanation."
  );

  print(response);

  if (response.trim() == "option_1") {
    return "Enter the Known Name of the location or place you want to see the available houses in:";
  } else if (response.trim() == "option_2") {
    return "Viewing all locations with available houses.";
  }else if (response.trim() == "option_3") {
    return "Report for an emergency.";
  }else if (response.trim() == "option_4") {
    return "houses by specifications";
  }else if (response.trim() == "option_5") {
    return "See all vacant houses";
  }
  else {
    return "I didn't understand your choice. Please reply with a value 1 to 5 or correct option";
  }
}


Future<bool> detectGoBackToServiceList(String userMessage) async {
  final prompt = '''
check for me if this  $userMessage has any meaning of going back or relates to going back to something ,returning ,choose another option
,redo ,reset ,start again or any things that relates to returning if it does relate then 
return true if not return false ,
only return true or false 
''';

  final response = await aiService.getAIResponse(prompt);
  print("Go Back Detection: $response");

  return response.trim().toLowerCase() == 'true';
}


Future<bool> validateLocation(String location) async {


  String response = await aiService.getAIResponse(
      "Is '$location' a valid place name?check first in kakamega before the rest of the world if it is a real place or name of a place. Reply only with 'yes' or 'no'."
  );

  return response.trim().toLowerCase() == "yes";
}


String? validateAndFormatKenyanPhone(String input) {
  input = input.replaceAll(RegExp(r'[^\d+]'), '');

  if (input.startsWith('+')) {
    input = input.substring(1); // remove '+'
  }

  if (input.startsWith('07') && input.length == 10) {
    return '254' + input.substring(1);
  } else if (input.startsWith('01') && input.length == 10) {
    return '254' + input.substring(1);
  } else if (input.startsWith('254') && input.length == 12) {
    return input;
  } else if (input.length == 9 && (input.startsWith('7') || input.startsWith('1'))) {
    return '254' + input;
  }

  return null; // invalid
}





Future<bool> validatePhoneNumber(String phn) async {


  String response = await aiService.getAIResponse(
      "Is '$phn' a valid kenyan number? having 12 digits,and starting with 254 .Reply only with 'yes' or 'no'."
  );

  return response.trim().toLowerCase() == "yes";
}


Future<bool> validateFullName(String fullName) async {
  String response = await aiService.getAIResponse(
      "Is '$fullName' a valid human name? The name should consist of two meaningful words that resemble real names, and it should not be random characters, offensive words, or nonsense. Reply only with 'yes' or 'no'."
  );

  return response.trim().toLowerCase() == "yes";
}



bool isValidKenyanPhoneNumber(String phoneNumber) {
  return RegExp(r'^254\d{9}$').hasMatch(phoneNumber);
}




Future<Map<String, dynamic>> getLocationDetails(String location) async {

  String response = await aiService.getAIResponse("Provide structured JSON details for the location: $location. "
      "Include: name, address, latitude (lat), longitude (lng), region, and a relevant image URL. "
      "in long and latitude be accurate as possible you and round of to 5 digit place"
      "Start looking first in kakamega as your main focus before looking to other places"

      "Ensure the response is a valid JSON object **only**, without extra text or formatting like markdown.\n\n"
      "The JSON format should be:\n"
      "{\n"
      '"id": "<location_name>",\n'
      '"name": "<name>",\n'
      '"address": "<full_address>",\n'
      '"lat": <latitude>,\n'
      '"lng": <longitude>,\n'
      '"region": "<region>",\n'
      '"image": "<image_url>"\n'
      "}");



  String rawResponse = response.replaceAll(RegExp(r'```json|```'), '').trim();
  print(rawResponse);

  try {
    var locat= jsonDecode(rawResponse) as Map<String, dynamic>;
    print(locat);
    //  var houses=await chatService.getHousesByLocation(location);
    // print(houses);

    // locat["vacant"]=houses.length;
    locat["vacant"]=1;

    print(locat);
    return locat;

  } catch (e) {
    print("Error parsing AI response: $e");
    return {};
  }
}


Future<List<Map<String,dynamic>>> getLocationsToBeMarked(Future<List<String>> many_location) async {
  List<Map<String,dynamic>> locateit=[];
  List<String> locations=["Masinde Muliro University"];

  locations.addAll(await many_location);

  for(var location in locations){

    var codAi=  await getLocationDetails(location);
    print("am searchin"+location);
    var markCode=realIsFound(realcode, location.toLowerCase());

    print("binary $markCode");
    if(markCode!=null){
      codAi["name"]=location;
      codAi["lat"]=markCode.latitude;
      codAi["lng"]=markCode.longitude;
    }

    print("codeai $codAi");

    locateit.add(codAi);


  }

  print ("I am locate it $locateit");

  // [{id: Masinde Muliro University, name: Masinde Muliro University of Science and Technology, address: Kakamega-Webuye Rd, Kakamega, Kenya, lat: 0.28979, lng: 34.75052, region: Kakamega, Western Kenya, image: https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/MMUST_Administration_Block.jpg/1280px-MMUST_Administration_Block.jpg, vacant: 1},
  // {id: lurambi, name: Lurambi, address: Lurambi, Kakamega County, Kenya, lat: 0.2825, lng: 34.75361, region: Kakamega County, image: https://example.com/lurambi.jpg, vacant: 1}]

  return locateit;
}


Future<List<String>> extractAmenitiesFromText(String userText) async {
  String prompt = """
The following are valid housing amenities: Wi-Fi, Water, Security, Electricity.
From this user's request: "$userText", extract all amenities mentioned. Reply with a comma-separated list of only the amenities that match those in the list above. If none match, return an empty list.
""";

  String response = await aiService.getAIResponse(prompt);


  return response
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}


Future<List<String>> extractDescriptionKeywords(String userText) async {
  String prompt = """
Extract important keywords or phrases from this housing-related request: "$userText".
Return 3 to 5 short keywords or phrases that can help match housing descriptions, such as "spacious", "single room", "near town", etc.
Respond with a comma-separated list only.
""";

  String response = await aiService.getAIResponse(prompt);

  return response
      .split(',')
      .map((e) => e.trim().toLowerCase())
      .where((e) => e.isNotEmpty)
      .toList();
}

