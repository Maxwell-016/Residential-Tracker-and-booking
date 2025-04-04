import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/house_card.dart';
import 'package:flutter_frontend/View/Components/image_builder.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_frontend/services/image_picker_service.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../View-Model/utils/app_colors.dart';
import '../../../View-Model/utils/validator.dart';
import '../../../View-Model/view_model.dart';
import '../../../constants.dart';
import '../../Components/SimpleAppBar.dart';
import '../../Components/function_button.dart';
import '../../Components/snackbars.dart';
import '../../Components/text_field.dart';

class ViewAndUpdateListings extends StatefulWidget {
  const ViewAndUpdateListings({
    super.key,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
  });

  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;

  @override
  State<ViewAndUpdateListings> createState() => _ViewAndUpdateListingsState();
}

class _ViewAndUpdateListingsState extends State<ViewAndUpdateListings> {
  @override
  Widget build(BuildContext context) {
    Logger logger = Logger();
    final firebaseServicesProvider = FirebaseServices();
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: App_Bar(
              changeTheme: widget.changeTheme,
              changeColor: widget.changeColor,
              colorSelected: widget.colorSelected,
              title: "View Listings"),
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
                        imageUrl: houses[index]['Images'].isNotEmpty
                            ? houses[index]['Images'][0]
                            : null,
                        onDeletePressed: () async {
                          await dialogBox(context, 'Delete',
                              'Are you sure you want to delete house ${houses[index]['House Name']}',
                              () async {
                            try {
                              await firebaseServicesProvider
                                  .deleteDocById(houses[index]['House Name']);
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

final updatedImageNameProvider =
    StateProvider<List<String>>((ref) => ['Select images']);
final updatedImageFileProvider = StateProvider<List<Uint8List>>((ref) => []);

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
    ImagePickerService imagePickerService = ImagePickerService();
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
    useEffect(() {
      Future.microtask(() {
        ref.read(selectedHouseSize.notifier).state = house['House Size'];
        ref.read(houseLocationProvider.notifier).state = house['Location'];
        ref.read(bookingStatusProvider.notifier).state =
            house['isBooked'] ? 'Booked' : 'Not Booked';
      });
      return null;
    }, []);
    String selectedSize = ref.watch(selectedHouseSize);
    String selectedLocation = ref.watch(houseLocationProvider);
    String bookingStatus = ref.watch(bookingStatusProvider);

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

    List<String> areas = [
      'myala',
      'lurambi',
      'sichirayi',
      'amalemba',
      'kefinco',
      'milimani',
      'shinyalu',
      'koromatangi',
      'kakamega town',
      'mudiri',
      'lubao',
      'stage mandazi',
      'khayega'
    ];
    areas.sort((a, b) => a.compareTo(b));

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
                  ImageBuilder(
                      imageUrls: house['Images'],
                      width: width,
                      placeholderAsset: 'assets/launch.png'),
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

                            Column(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Location'),
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
                                    items: areas.map((entry) {
                                      return DropdownMenuItem(
                                        value: entry,
                                        child: Text(entry),
                                      );
                                    }).toList(),
                                    value: selectedLocation,
                                    onChanged: (String? value) {
                                      ref
                                          .read(houseLocationProvider.notifier)
                                          .state = value!;
                                    },
                                  ),
                                ),
                              ],
                            ),
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
                                child: GestureDetector(
                                  onTap: () async {
                                    List<Uint8List> imageFiles = [];
                                    List<String> imageNames = [];

                                    final images =
                                        await imagePickerService.pickImages();

                                    if (images != null && images.isNotEmpty) {
                                      for (final image in images) {
                                        imageFiles.add(image.bytes);
                                        imageNames.add(image.name);

                                        ref
                                            .read(updatedImageNameProvider
                                                .notifier)
                                            .state = imageNames;
                                        ref
                                            .read(updatedImageFileProvider
                                                .notifier)
                                            .state = imageFiles;
                                      }
                                    }
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  ),
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

                            // Column(
                            //   spacing: 10,
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     Text('Booking Status'),
                            //     Container(
                            //       decoration: BoxDecoration(
                            //           border: Border.all(
                            //             color: borderColor,
                            //             width: 1.0,
                            //           ),
                            //           borderRadius:
                            //               BorderRadius.circular(10.0)),
                            //       width: width,
                            //       child: DropdownButton(
                            //         padding: EdgeInsets.only(left: 20.0),
                            //         underline: SizedBox(),
                            //         menuWidth: width,
                            //         items:
                            //             ['Booked', 'Not Booked'].map((entry) {
                            //           return DropdownMenuItem(
                            //             value: entry,
                            //             child: Text(entry),
                            //           );
                            //         }).toList(),
                            //         value: bookingStatus,
                            //         onChanged: (String? value) {
                            //           ref
                            //               .read(bookingStatusProvider.notifier)
                            //               .state = value!;
                            //         },
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            FunctionButton(
                              text: 'Update Details',
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  await dialogBox(context, 'Update',
                                      'Are you sure you want to save the changes?',
                                      () async {
                                    try {
                                      List<String>? updatedUrls =
                                          await imagePickerService.uploadFiles(
                                              ref.watch(
                                                  updatedImageFileProvider));

                                      String? message =
                                          await firebaseServicesProvider
                                              .updateListings(
                                        houseNameController.text,
                                        selectedLocation,
                                        int.parse(priceController.text),
                                        selectedSize,
                                        updatedUrls,
                                        descController.text,
                                        selectedAmenities.value,
                                      );
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
                                    imageUrl: houses[index]['Images'].isNotEmpty
                                        ? houses[index]['Images'][0]
                                        : null,
                                    houseSize: houses[index]['House Size'],
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
