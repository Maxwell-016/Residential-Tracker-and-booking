import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class Landlord {
  final String id;
  final String name;
  final String email;
  final String phone;

  Landlord({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory Landlord.fromJson(Map<String, dynamic> json) {
    return Landlord(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}



Future<List<Landlord>> fetchLandlords() async {
  final response = await http.get(Uri.parse('http://your-api-url.com/landlords'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Landlord.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load landlords');
  }
}




// Assume Landlord model and fetchLandlords function are here

class ViewLandlordsScreen extends StatelessWidget {
  const ViewLandlordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Landlords')),
      body: FutureBuilder<List<Landlord>>(
        future: fetchLandlords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No landlords found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final landlord = snapshot.data![index];
                return ListTile(
                  title: Text(landlord.name),
                  subtitle: Text('${landlord.email} | ${landlord.phone}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
