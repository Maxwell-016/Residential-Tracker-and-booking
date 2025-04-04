import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/firebase_services.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  late Future <Map<String,dynamic>> houseSearched;
  FirebaseServices firebaseServices = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    FocusNode searchFocus = FocusNode();
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          focusNode: searchFocus,
          enabled: true,
          expands: true,
          textInputAction: TextInputAction.done,
        ),
      ),
      body: SingleChildScrollView(

      ),
    ),
    );
  }
}
