
import 'dart:convert';

import 'package:http/http.dart' as http;

Future<String> sendEmailViaApi({
  required String to,
  required String hsName,

}) async {

  final String apiUrl = 'https://mpesaapi.onrender.com/send-email';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'to': to,
        'subject': "Urgent: House Booking Expiry",
        'body':  "<h3>Your house $hsName booking is about to expire! </h3><p>Please make a payment to continue staying.</p>",
      }),
    );

    if (response.statusCode == 200) {
      return "Email sent successfully!";
    } else {
      print("Failed with status: ${response.statusCode}");
      print("Response body: ${response.body}");
      return "Failed to send email.";
    }
  } catch (e) {
    print("Error: $e");
    return "Error sending email.";
  }
}