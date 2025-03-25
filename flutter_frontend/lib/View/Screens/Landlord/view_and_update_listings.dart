import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/house_card.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../View-Model/utils/app_colors.dart';
import '../../../View-Model/utils/validator.dart';
import '../../../View-Model/view_model.dart';
import '../../Components/function_button.dart';
import '../../Components/snackbars.dart';
import '../../Components/text_field.dart';

class ViewAndUpdateListings extends StatefulWidget {
  const ViewAndUpdateListings({super.key});

  @override
  State<ViewAndUpdateListings> createState() => _ViewAndUpdateListingsState();
}

class _ViewAndUpdateListingsState extends State<ViewAndUpdateListings> {
  @override
  Widget build(BuildContext context) {
    final firebaseServicesProvider = FirebaseServices();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(size: 30.0),
          centerTitle: true,
          title: Text("View Listings"),
        ),
        body: FutureBuilder(
            future: firebaseServicesProvider.getHouseListing(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 50.0,
                  ),
                );
              }
              if (snapshot.data == null || snapshot.data!.isEmpty) {
                return Center(
                  child: Text('You have no houses'),
                );
              }
              List<Map<String, dynamic>> houses = snapshot.data!;
              return GridView.builder(
                  itemCount: houses.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      mainAxisExtent: 300,
                      mainAxisSpacing: 30,
                      crossAxisSpacing: 30),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HouseDetails(
                              house: houses[index],
                              othersLength: houses.length,
                            ),
                          ),
                        );
                      },
                      child: HouseCard(
                        houseName: houses[index]['House Name'],
                        price: houses[index]['House Price'].toString(),
                        houseSize: houses[index]['House Size'],
                        onDeletePressed: () async {
                          await dialogBox(context, 'Delete',
                              'Are you sure you want to delete house ${houses[index]['House Name']}',
                              () async {
                            try {
                              await firebaseServicesProvider
                                  .deleteDocById(houses[index]['Id']);
                              setState(() {});
                              if (!context.mounted) return;
                              SnackBars.showSuccessSnackBar(context,
                                  'House ${houses[index]['House Name']} deleted successfully');
                              Navigator.pop(context);
                            } catch (e) {
                              if (!context.mounted) return;
                              SnackBars.showErrorSnackBar(context,
                                  'An error occurred trying to delete house ${houses[index]['House Name']}');
                              Navigator.pop(context);
                            }
                          });
                        },
                      ),
                    );
                  });
            }),
      ),
    );
  }
}

class HouseDetails extends HookConsumerWidget {
  final Map<String, dynamic> house;
  final int othersLength;
  const HouseDetails({
    super.key,
    required this.house,
    required this.othersLength,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesProvider = ref.watch(firebaseServices);
    final viewModelProvider = ref.watch(viewModel);
    Logger logger = Logger();
    final formKey = GlobalKey<FormState>();
    TextEditingController houseNameController =
        useTextEditingController(text: house['House Name']);
    FocusNode houseNameFocus = useFocusNode();
    TextEditingController priceController =
        useTextEditingController(text: house['House Price'].toString());
    FocusNode priceFocus = useFocusNode();
    TextEditingController descController =
        useTextEditingController(text: house['Description']);
    FocusNode descFocus = useFocusNode();
    Future.microtask(() {
      ref.read(selectedHouseSize.notifier).state = house['House Size'];
    });
    String selectedSize = ref.watch(selectedHouseSize);

    final selectedAmenities =
        useState<List<dynamic>>(house['Available Amenities']);

    final amenities = useState<Map<String, bool>>({
      'Wi-Fi': selectedAmenities.value.contains('Wi-Fi'),
      'Parking': selectedAmenities.value.contains('Parking'),
      'Gym': selectedAmenities.value.contains('Gym'),
      'Security': selectedAmenities.value.contains('Security'),
      'Water': selectedAmenities.value.contains('Water'),
      'Electricity': selectedAmenities.value.contains('Electricity'),
    });

    String imageName = 'Select images';

    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color borderColor =
        isDark ? AppColors.lightThemeBackground : AppColors.darkThemeBackground;
    final deviceWidth = MediaQuery.of(context).size.width;

    double width = deviceWidth > 800 ? deviceWidth / 2.2 : deviceWidth / 1.1;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(size: 30.0),
          centerTitle: true,
          title: Text("Update Listing"),
        ),
        body: CustomScrollView(
          slivers: [
            //image and update form
            SliverToBoxAdapter(
              child: Wrap(
                spacing: 20.0,
                runSpacing: 20.0,
                children: [
                  Column(
                    spacing: 30.0,
                    children: [
                      //display the images of the house
                      Image.asset(
                        'assets/launch.png',
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                        width: width,
                      ),
                      Image.asset(
                        'assets/launch.png',
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                        width: width,
                      ),
                      Image.asset(
                        'assets/launch.png',
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                        width: width,
                      ),
                    ],
                  ),
                  //form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          spacing: 20.0,
                          children: [
                            MyTextField(
                                label: 'House Name',
                                placeHolder: 'e.g. C05',
                                controller: houseNameController,
                                icon: Icon(Icons.house_outlined),
                                fieldValidator: Validators.fieldValidator,
                                focusNode: houseNameFocus,
                                width: width),
                            //location selection
                            MyTextField(
                                label: 'Price',
                                placeHolder: 'e,g. 4000',
                                controller: priceController,
                                icon: Icon(Icons.price_change_outlined),
                                fieldValidator: Validators.intFieldValidator,
                                focusNode: priceFocus,
                                width: width),
                            Column(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('House Size'),
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: borderColor,
                                        width: 1.0,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  width: width,
                                  child: DropdownButton(
                                    padding: EdgeInsets.only(left: 20.0),
                                    underline: SizedBox(),
                                    menuWidth: width,
                                    items: [
                                      'Single',
                                      'Bedsitter',
                                      'One bedroom',
                                      '2 bedroom'
                                    ].map((entry) {
                                      return DropdownMenuItem(
                                        value: entry,
                                        child: Text(entry),
                                      );
                                    }).toList(),
                                    value: selectedSize,
                                    onChanged: (String? value) {
                                      ref
                                          .read(selectedHouseSize.notifier)
                                          .state = value!;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                                onTap: () {
                                  // logger.i('Images field');
                                  // imagePickerService.pickImages();
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 10,
                                  children: [
                                    Text('Images'),
                                    Container(
                                      width: width,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        border: Border.all(
                                            color: borderColor, width: 1.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Text(
                                          imageName,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14.0),
                                        ),
                                      ),
                                    )
                                  ],
                                )),
                            MyTextField(
                                label: 'Description',
                                placeHolder: 'Describe your house',
                                controller: descController,
                                icon: Icon(Icons.details_outlined),
                                fieldValidator: Validators.fieldValidator,
                                focusNode: descFocus,
                                maxLines: 5,
                                width: width),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 10,
                              children: [
                                Text('Amenities'),
                                Container(
                                  width: width,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: borderColor, width: 1),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20.0),
                                    child: Center(
                                      child: Wrap(
                                        spacing: 40.0,
                                        runSpacing: 20.0,
                                        children: amenities.value.entries
                                            .map((entry) {
                                          return SizedBox(
                                            //width: width / 3,
                                            child: CheckboxListTile(
                                                hoverColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                title: Text(entry.key),
                                                value: entry.value,
                                                onChanged: (value) {
                                                  amenities.value = {
                                                    ...amenities.value,
                                                    entry.key: value ?? false,
                                                  };
                                                  if (value ?? false) {
                                                    selectedAmenities.value = [
                                                      ...selectedAmenities
                                                          .value,
                                                      entry.key
                                                    ];
                                                  } else {
                                                    selectedAmenities.value =
                                                        selectedAmenities.value
                                                            .where((item) =>
                                                                item !=
                                                                entry.key)
                                                            .toList();
                                                  }
                                                }),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            FunctionButton(
                              text: 'Update Details',
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  await dialogBox(context, 'Update',
                                      'Are you sure you want to save the changes?',
                                      () async {
                                    try {
                                      String? message =
                                          await firebaseServicesProvider
                                              .updateListings(
                                                  house['Id'],
                                                  houseNameController.text,
                                                  int.parse(
                                                      priceController.text),
                                                  selectedSize,
                                                  null,
                                                  descController.text,
                                                  selectedAmenities.value);
                                      if (!context.mounted) return;
                                      if (message == null) {
                                        SnackBars.showSuccessSnackBar(context,
                                            'House ${houseNameController.text} updated successfully');
                                        Navigator.pop(context);
                                      }
                                      if (message == 'No Change') {
                                        SnackBars.showInfoSnackBar(context,
                                            'No changes made on House ${houseNameController.text}');
                                        Navigator.pop(context);
                                      }
                                    } catch (e) {
                                      logger.e(e);
                                      SnackBars.showErrorSnackBar(context,
                                          'An error occurred trying to update House ${houseNameController.text}. Please try again');
                                      Navigator.pop(context);
                                    }
                                  });
                                }
                              },
                              btnColor: AppColors.deepBlue,
                              width: width,
                            ),
                            //image picker
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //other houses
            SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisExtent: 300,
                  mainAxisSpacing: 30,
                  crossAxisSpacing: 30,
                ),
                delegate: SliverChildBuilderDelegate(childCount: othersLength,
                    (context, index) {
                  return FutureBuilder(
                      future: firebaseServicesProvider.getHouseListing(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 50.0,
                            ),
                          );
                        }
                        if (snapshot.data == null || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text('You have no other houses'),
                          );
                        }
                        List<Map<String, dynamic>> houses = snapshot.data!;
                        return StatefulBuilder(builder: (context, setState) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HouseDetails(
                                    house: houses[index],
                                    othersLength: houses.length,
                                  ),
                                ),
                              );
                            },
                            child: index < houses.length
                                ? HouseCard(
                                    houseName: houses[index]['House Name'],
                                    price:
                                        houses[index]['House Price'].toString(),
                                    houseSize: houses[index]['House Size'],
                                    // onDeletePressed: () async {
                                    //   await dialogBox(context, 'Delete',
                                    //       'Are you sure you want to delete house ${houses[index]['House Name']}',
                                    //       () async {
                                    //     try {
                                    //       await firebaseServicesProvider
                                    //           .deleteDocById(
                                    //               houses[index]['Id']);
                                    //       setState(() {
                                    //         houses.removeAt(index);
                                    //       });
                                    //       if (!context.mounted) return;
                                    //       SnackBars.showSuccessSnackBar(context,
                                    //           'House ${houses[index]['House Name']} deleted successfully');
                                    //       Navigator.pop(context);
                                    //     } catch (e) {
                                    //       if (!context.mounted) return;
                                    //       SnackBars.showErrorSnackBar(context,
                                    //           'An error occurred trying to delete house ${houses[index]['House Name']}');
                                    //       Navigator.pop(context);
                                    //     }
                                    //   });
                                    // }
                                    )
                                : null,
                          );
                        });
                      });
                })
                //items
                ),
          ],
        ),
      ),
    );
  }
}
