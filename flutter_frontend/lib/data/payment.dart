import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'notifications.dart';



  String? checkoutRequestID;
final FirebaseFirestore fs = FirebaseFirestore.instance;

  Future<void> initiatePayment(String studentPhone, double amountToPay, String studentEmail,
      String studentName, String houseName, String location,
      String landlordPhone, String landlordId, String lname,
      String houseId, List<String> houseImages, String paymentOption,double lat,double long) async {

    try {
      var response = await http.post(
        Uri.parse("https://mpesaapi.onrender.com/stkpush"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": studentPhone,
          "amount": amountToPay,
        }),
      );

      print("I am from stkpush ${response.statusCode}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        checkoutRequestID = data["CheckoutRequestID"];  // Save dynamically

        print("STK Push Sent Successfully: $checkoutRequestID");

        bool paymentSuccess = await checkPaymentStatus();

        if (paymentSuccess) {
          await fs.collection("booked_students").doc().set({
            "email": studentEmail,
            "name": studentName ?? "Unknown",
            "stdContact": studentPhone,
            "houseName": houseName,
            "lat":lat,
              "long":long,
            "houseLocation": location,
            "paymentOption":paymentOption,
            'timestamp': FieldValue.serverTimestamp(),
            "payment_status": "Paid",
            "amount_paid": amountToPay,
            "landlordContact": landlordPhone,
            "landlordId": landlordId,
            "landlord": lname,
            "images": houseImages
          });

          await fs.collection("Landlords")
              .doc(landlordId)
              .collection("Houses")
              .doc(houseId)
              .update({"isBooked": true});

          String msg="$houseName has been booked successfully with the '$paymentOption' option!";
               print(msg  );
               trigernotification(null, msg, "House Booked Successfully");


        } else {

            // return "Payment failed or timed out. Please try again.";
            trigernotification(null,  "Payment failed or timed out. Please try again.", "Payment failed!!");

        }
      } else {

          // return "STK Push request failed. Try again.";
          trigernotification(null,  "STK Push request failed. Try again.", "Payment failed!!");

      }
    } catch (e) {

      trigernotification(null, e.toString(), "Payment failed!!");
       // return "Error: ${e.toString()}";

    }
  }


  Future<bool> checkPaymentStatus() async {
    if (checkoutRequestID == null) {
      print("No CheckoutRequestID available.");
      return false;
    }

    for (int i = 0; i < 5; i++) {
      await Future.delayed(Duration(seconds: 10));

      try {
        var callbackResponse = await http.post(
          Uri.parse("https://mpesaapi.onrender.com/callback"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "CheckoutRequestID": checkoutRequestID
          }),
        );

        print("i am call back ${callbackResponse.statusCode}");
        print("Callback Response: ${callbackResponse.body}");

        if (callbackResponse.statusCode == 200) {
          var data = jsonDecode(callbackResponse.body);
          if (data["status"] == "ok") {
            print("Payment confirmed!");
            return true;
          }
        }
      } catch (e) {
        print("Error checking payment status: $e");
      }
    }
    return false;
  }

