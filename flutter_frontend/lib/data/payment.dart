import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/snackbars.dart';
import 'package:flutter_frontend/data/providers.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'notifications.dart';

import 'dart:html' as html;

  String? checkoutRequestID;
final FirebaseFirestore fs = FirebaseFirestore.instance;

  Future<void> initiatePayment(String studentPhone, double amountToPay, String studentEmail,
      String studentName, String houseName, String location,
      String landlordPhone, String landlordId, String lname,
      String houseId, List<String> houseImages, String paymentOption,double lat,double long,BuildContext context,ref) async {


    print("Phn for payment $studentPhone amount ${ amountToPay/1000}");
    try {
      var response = await http.post(
        Uri.parse("https://mpesaapi.onrender.com/stkpush"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
           "phone": studentPhone,
          // "phone": "254700742362",
          "amount": (amountToPay/1000).toInt(),
        }),
      );

      print("I am from stkpush ${response.statusCode}");
      print("Phn for payment $studentPhone amount ${ amountToPay/1000}");
      var data = jsonDecode(response.body);
print("I am from api $data");


      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        checkoutRequestID = data["CheckoutRequestID"];  // Save dynamically

        print("STK Push Sent Successfully: $checkoutRequestID");

        bool paymentSuccess = await checkPaymentStatus();

        if (paymentSuccess) {
          await fs.collection("booked_students").doc(houseId).set({
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
          html.Notification.permission == 'granted'?
               trigernotification(context, msg, "House Booked Successfully"):
               SnackBars.showSuccessSnackBar(context, msg);

          ref.read(isBooked.notifier).state = true;

        } else {

            // return "Payment failed or timed out. Please try again.";
          html.Notification.permission == 'granted'?
            trigernotification(context,  "Payment failed or timed out. Please try again.", "Payment failed!!"):
            SnackBars.showErrorSnackBar(context,  "Payment failed or timed out. Please try again.");

        }
      } else {

          // return "STK Push request failed. Try again.";
        html.Notification.permission == 'granted'?
          trigernotification(context,  "STK Push request failed. Try again.", "Payment failed!!"):
          SnackBars.showErrorSnackBar(context,  "STK Push request failed. Try again.");

      }
    } catch (e) {
      html.Notification.permission == 'granted'?
      trigernotification(context, e.toString(), "Payment failed!!"):
      SnackBars.showErrorSnackBar(context,  e.toString());
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

