import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/view_model.dart';
import 'package:flutter_frontend/View/Components/function_button.dart';
import 'package:flutter_frontend/View/Components/google_fonts.dart';
import 'package:flutter_frontend/View/Components/house_card.dart';
import 'package:flutter_frontend/View/Components/image_builder.dart';
import 'package:flutter_frontend/View/Components/snackbars.dart';
import 'package:flutter_frontend/View/Screens/Landlord/search_page.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../View-Model/utils/app_colors.dart';
import '../../../constants.dart';
import '../../Components/SimpleAppBar.dart';

class UpdateHouseStatus extends HookConsumerWidget {
  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;
  const UpdateHouseStatus(
      {super.key,
      required this.colorSelected,
      required this.changeTheme,
      required this.changeColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Logger logger = Logger();
    final firebaseServicesProvider = ref.watch(firebaseServices);
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color borderColor =
        isDark ? AppColors.lightThemeBackground : AppColors.darkThemeBackground;

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: App_Bar(
            changeTheme: changeTheme,
            changeColor: changeColor,
            colorSelected: colorSelected,
            title: "",
            search: GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
              },
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: borderColor,
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 5.0, right: 15.0),
                    child: Row(
                      spacing: 5.0,
                      children: [
                        Icon(Icons.search),
                        Text(
                          'Search house by house name',
                          style: TextStyle(fontSize: 15.0),
                        ),
                      ],
                    ),
                  ),
              ),
            ),
          ),
        ),
        body: FutureBuilder(
            future: firebaseServicesProvider.getHouseListingStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error fetching houses'),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text('You have no booked houses'),
                );
              }
              List<Map<String, dynamic>> houseDetails = snapshot.data!;

              return GridView.builder(
                  itemCount: houseDetails.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      mainAxisExtent: 300,
                      mainAxisSpacing: 30,
                      crossAxisSpacing: 30),
                  itemBuilder: (context, index) {
                    logger.i(houseDetails[index]);
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeHouseStatus(
                              houseDetails: houseDetails[index],
                            ),
                          ),
                        );
                      },
                      child: HouseCard(
                        isNotMoney: true,
                        houseName:
                            'House Name: ${houseDetails[index]['House Name']}',
                        price: 'Tenant: ${houseDetails[index]['tenant']}',
                        houseSize:
                            'Status: ${houseDetails[index]['isBooked'] ? 'Booked' : 'Available'}',
                        imageUrl: houseDetails[index]['Images'][0].toString(),
                      ),
                    );
                  });
            }),
      ),
    );
  }
}

class ChangeHouseStatus extends HookConsumerWidget {
  final Map<String, dynamic> houseDetails;
  const ChangeHouseStatus({super.key, required this.houseDetails});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesProvider = ref.watch(firebaseServices);
    final deviceWidth = MediaQuery.of(context).size.width;
    Logger logger = Logger();

    double width = deviceWidth > 800 ? deviceWidth / 2.2 : deviceWidth / 1.3;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Center(
            child: Wrap(
              spacing: 60.0,
              runSpacing: 60.0,
              children: [
                ImageBuilder(
                  imageUrls: houseDetails['Images'],
                  width: width,
                  placeholderAsset: 'assets/launch.png',
                ),
                Padding(
                  padding: deviceWidth < 800
                      ? const EdgeInsets.only(left: 50.0)
                      : const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 30.0,
                      children: [
                        UseFont(
                            text: 'House Name: ${houseDetails['House Name']}',
                            myFont: 'Open Sans',
                            size: 20.0),
                        UseFont(
                            text: 'Tenant : ${houseDetails['tenant']}',
                            myFont: 'Open Sans',
                            size: 20.0),
                        UseFont(
                            text: 'Location: ${houseDetails['Location']}',
                            myFont: 'Open Sans',
                            size: 20.0),
                        UseFont(
                            text: 'House Price: ${houseDetails['House Price']}',
                            myFont: 'Open Sans',
                            size: 20.0),
                        UseFont(
                            text: 'House Size: ${houseDetails['House Size']}',
                            myFont: 'Open Sans',
                            size: 20.0),
                        UseFont(
                            text: houseDetails['Description'].toString(),
                            myFont: 'Open Sans',
                            size: 20.0),
                         FunctionButton(
                                        width: width,
                                        text: 'Mark as Available',
                                        onPressed: () async{
                                          await dialogBox(
                                              context,
                                              'Update House',
                                              'Are you sure you want to mark this house as Available? ',
                                              () async{
                                                try {
                                                  firebaseServicesProvider
                                                      .markRoomAsAvailable(
                                                      houseDetails['House Name']);
                                                  SnackBars.showSuccessSnackBar(context,
                                                      'House Status updates Successfully');
                                                  Navigator.pop(context);
                                                } catch (e) {
                                                  logger.e(e);
                                                  SnackBars.showErrorSnackBar(context,
                                                      'An error occurred trying to update the house status');
                                                  Navigator.pop(context);
                                                }
                                              },
                                              firebaseServicesProvider.isMarkingAvailable
                                          );
                                        },
                                        textColor: Colors.white,
                                        btnColor: AppColors.booked),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
