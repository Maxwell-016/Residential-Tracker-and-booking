


  import 'dart:convert';

import 'package:http/http.dart' as http;

Future<void> WakeUpServer() async {
    try {
      var response = await http.post(
        Uri.parse("https://mpesaapi.onrender.com/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ping": "ping",

        }),
      );

      print("I am from ping ${response.statusCode}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);


      } else {
        print('Server responded, but not ready yet. ');
      }
    } catch (e) {
      print('Error waking up server: $e');
    }
  }
