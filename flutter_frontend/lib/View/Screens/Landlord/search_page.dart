import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/house_card.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:logger/logger.dart';

import '../../../View-Model/utils/app_colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();
  FirebaseServices firebaseServices = FirebaseServices();
  Logger logger = Logger();

  Map<String, dynamic>? results = {};
  bool isLoading = false;
  String? errorMessage;

  Future<void> searchHouse(String name) async {
    if (name.isEmpty) {
      setState(() {
        errorMessage = 'please enter a house name to search';
        results = {};
      });
      return;
    }
    setState(() {
      isLoading = true;
      results = {};
      errorMessage = null;
    });

    try {
      Map<String, dynamic>? searchResults =
          await firebaseServices.getSearchedHouse(name);
      setState(() {
        if (searchResults != null) {
          results = searchResults;
        } else {
          errorMessage = 'No house found with name $name';
        }
      });
      logger.i(results);
    } catch (e) {
      logger.e(e);
      setState(() {
        errorMessage = 'An error occurred while searching';
        results = {};
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color borderColor =
        isDark ? AppColors.lightThemeBackground : AppColors.darkThemeBackground;
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(

          //TODO: try to use both uppercase and lowercase to fetch
          title: TextField(
            controller: searchController,
            focusNode: searchFocus,
            enabled: true,
            textInputAction: TextInputAction.search,
            onSubmitted: (value) async => await searchHouse(value.trim()),
            decoration: InputDecoration(
              hintText: 'Search house by house name',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14.0),
              suffixIcon: IconButton(
                  onPressed: () async {
                    await searchHouse(searchController.text.trim());
                  },
                  icon: Icon(Icons.search)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(width: 1.0, color: borderColor)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    width: 1.0,
                    color: borderColor,
                  )),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: deviceHeight / 4,),
              if (isLoading) Center(child: CircularProgressIndicator()),
              if (errorMessage != null) Center(child: Text(errorMessage!)),
              if (results!.isNotEmpty)
                Center(
                  child: SizedBox(
                    width: deviceWidth / 2,

                    //TODO: add an onTap function that takes you to the description page to mark it as available
                    child: HouseCard(
                        isNotMoney: true,
                        imageUrl: results!['images'][0],
                        houseName: 'House Name: ${results!['houseName']}',
                        price: 'Tenant: ${results!['name']}',
                        houseSize: 'Status: Booked'),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
