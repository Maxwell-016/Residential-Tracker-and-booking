import 'dart:convert';

import '../data/chart_provider.dart';

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
          "Do NOT return any extra text or explanation."
  );

  print(response);

  if (response.trim() == "option_1") {
    return "Enter the Known Name of the location or place you want to see the available houses in:";
  } else if (response.trim() == "option_2") {
    return "Viewing all locations with available houses.";
  }else if (response.trim() == "option_3") {
    return "You have selected option 3:  Report for an emergency.";
  }else if (response.trim() == "option_4") {
    return "You have selected option 4: Ask for help and related questions.";
  }else if (response.trim() == "option_5") {
    return "You have selected option 5: Send feedback to the landlord";
  }
  else {
    return "I didn't understand your choice. Please reply with a value 1 to 5 or correct option";
  }
}




Future<bool> validateLocation(String location) async {


  String response = await aiService.getAIResponse(
      "Is '$location' a valid place name? Reply only with 'yes' or 'no'."
  );

  return response.trim().toLowerCase() == "yes";
}

Future<bool> validatePhoneNumber(String phn) async {


  String response = await aiService.getAIResponse(
      "Is '$phn' a valid kenyan number? having 12 digits,and starting with 254 .Reply only with 'yes' or 'no'."
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


Future<List<Map<String,dynamic>>> getLocationsToBeMarked() async {
 List<Map<String,dynamic>> locateit=[];
  List<String> locations=["Masinde Muliro University"];

 locations.addAll(await chatService.getAllLocations());

  for(var location in locations){
    locateit.add(await getLocationDetails(location));
  }


return locateit;
}

