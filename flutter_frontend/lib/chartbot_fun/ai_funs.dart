import '../data/chart_provider.dart';

AIService aiService = AIService();


//
// Future<String> validateOption(String userMessage) async {
//
//
//   String response = await aiService.getAIResponse(
//       "Classify this response: '$userMessage'. Possible outputs: option_1, option_2. ,Only return one of these values,and here here even if the respose is one or 1 that he has selected option 1 and talk as if you are answering to the user who send the responce directly, ONLY if the response doesnot fall in the any of the option give why is the response not among the option and advice the user to choose the available option briefly");
//   print(response);
//
//   if(response.trim() =="option_1" ){
//     return "Enter the Known Name of the  location or place you want to see the available houses in";
//
//
//
//   } else if (response.trim() == "option_2") {
//   return "You have selected option 2: Viewing all locations with available houses.";
//
//   } else {
//     return response;
//
//   }

// }



Future<String> validateOption(String userMessage) async {
  AIService aiService = AIService();

  String response = await aiService.getAIResponse(
      "Classify this response: '$userMessage'. Possible outputs: option_1, option_2, invalid. "
          "If the user intends to select option 1, return 'option_1'. "
          "If the user intends to select option 2, return 'option_2'. "
          "If the response is completely unrelated, return 'invalid'. "
          "Do NOT return any extra text or explanation."
  );

  print(response);

  if (response.trim() == "option_1") {
    return "Enter the Known Name of the location or place you want to see the available houses in:";
  } else if (response.trim() == "option_2") {
    return "You have selected option 2: Viewing all locations with available houses.";
  } else {
    return "I didn't understand your choice. Please reply with 1 or 2.";
  }
}




Future<bool> validateLocation(String location) async {
  AIService aiService = AIService();

  String response = await aiService.getAIResponse(
      "Is '$location' a valid place name? Reply only with 'yes' or 'no'."
  );

  return response.trim().toLowerCase() == "yes";
}



