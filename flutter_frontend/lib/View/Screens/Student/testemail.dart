import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class EmailSenderScreen extends StatelessWidget {
  const EmailSenderScreen({super.key});



  Future<String> sendEmailViaApi({
    required String to,
  }) async {

    final String apiUrl = 'https://mpesaapi.onrender.com/send-email';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': to,
          'subject': "Urgent: House Booking Expiry",
          'body':  "<h3>Your house booking is about to expire! </h3><p>Please make a payment to continue staying.</p>",
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Send Email via SendGrid")),
      body: Center(
        child:TextButton(
              onPressed: () async {
                String result = await sendEmailViaApi(
                  to:  "comb01-048722022@student.mmust.ac.ke",
                );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Email $result")),
            );
          },
          child: const Text("Send Email in Background"),
        ),
      )
    );
  }
}
