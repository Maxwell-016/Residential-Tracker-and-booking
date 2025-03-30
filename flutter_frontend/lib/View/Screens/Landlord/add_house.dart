import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/utils/validator.dart';
import 'package:flutter_frontend/View-Model/view_model.dart';
import 'package:flutter_frontend/View/Components/function_button.dart';
import 'package:flutter_frontend/View/Components/landlord_side_nav.dart';
import 'package:flutter_frontend/View/Components/text_field.dart';
import 'package:flutter_frontend/services/image_picker_service.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../View-Model/utils/app_colors.dart';
import '../../Components/snackbars.dart';


final imageNameProvider = StateProvider<List<String>>((ref) => ['Select images'] );
final imageFileProvider = StateProvider<List<Uint8List>>((ref) => [] );

class AddHouse extends HookConsumerWidget {
  final double width;
  const AddHouse({
    super.key,
    required this.width,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    TextEditingController houseNameController = useTextEditingController();
    FocusNode houseNameFocus = useFocusNode();
    TextEditingController priceController = useTextEditingController();
    FocusNode priceFocus = useFocusNode();
    TextEditingController descController = useTextEditingController();
    FocusNode descFocus = useFocusNode();
    String selectedSize = ref.watch(selectedHouseSize);
    String selectedLocation = ref.watch(houseLocationProvider);
    String bookingStatus = ref.watch(bookingStatusProvider);
    Logger logger = Logger();
    ImagePickerService imagePickerService = ImagePickerService();


    List<String> imageName = ref.watch(imageNameProvider);

    final amenities = useState<Map<String, bool>>({
      'Wi-Fi': false,
      'Parking': false,
      'Gym': false,
      'Security': false,
      'Water': false,
      'Electricity': false,
    });
    List<String> areas =[
      'Myala',
      'Lurambi',
      'Sichirayi',
      'Amalemba',
      'Kefinco',
      'Milimani',
      'Shinyalu',
      'Koromatangi',
      'Kakamega Town',
      'Mudiri',
      'Lubao',
      'Stage Mandazi',
      'Khayega'
    ];
    areas.sort((a,b) => a.compareTo(b));

    final selectedAmenities = useState<List<String>>([]);

    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color borderColor =
        isDark ? AppColors.lightThemeBackground : AppColors.darkThemeBackground;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(size: 30.0),
          centerTitle: true,
          title: Text("Manage House Listings"),
          actions: [
            // ThemeButton(changeThemeMode: changeTheme),
            // ColorButton(changeColor: changeColor, colorSelected: colorSelected)
          ],
        ),
        drawer: LandlordSideNav(),
        body: SingleChildScrollView(
          child: Center(
            child: Card(
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
                                borderRadius: BorderRadius.circular(10.0)),
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
                                ref.read(houseLocationProvider.notifier).state =
                                    value!;
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
                                borderRadius: BorderRadius.circular(10.0)),
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
                                ref.read(selectedHouseSize.notifier).state =
                                    value!;
                              },
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () async{

                            List<Uint8List> imageFiles = [];
                            List<String> imageNames = [];

                            final images = await imagePickerService.pickImages();

                            if(images != null && images.isNotEmpty) {

                              for (final image in images) {
                                imageFiles.add(image.bytes);
                                imageNames.add(image.name);

                                ref.read(imageNameProvider.notifier).state = imageNames;
                                ref.read(imageFileProvider.notifier).state = imageFiles;
                              }
                            }
                            //  List<String>? urls = await imagePickerService.uploadFiles(imageFiles);
                            // logger.i(urls);

                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                              Text('Images'),
                              Container(
                                width: width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                      color: borderColor, width: 1.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                    imageName.toString(),
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14.0),
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
                                border:
                                    Border.all(color: borderColor, width: 1),
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20.0),
                              child: Center(
                                child: Wrap(
                                  spacing: 40.0,
                                  runSpacing: 20.0,
                                  children:
                                      amenities.value.entries.map((entry) {
                                    return SizedBox(
                                      width: width / 3,
                                      child: CheckboxListTile(
                                          hoverColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
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
                                                ...selectedAmenities.value,
                                                entry.key
                                              ];
                                            } else {
                                              selectedAmenities.value =
                                                  selectedAmenities.value
                                                      .where((item) =>
                                                          item != entry.key)
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
                      Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Booking Status'),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: borderColor,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(10.0)),
                            width: width,
                            child: DropdownButton(
                              padding: EdgeInsets.only(left: 20.0),
                              underline: SizedBox(),
                              menuWidth: width,
                              items: ['Booked', 'Not Booked'].map((entry) {
                                return DropdownMenuItem(
                                  value: entry,
                                  child: Text(entry),
                                );
                              }).toList(),
                              value: bookingStatus,
                              onChanged: (String? value) {
                                ref.read(bookingStatusProvider.notifier).state =
                                    value!;
                              },
                            ),
                          ),
                        ],
                      ),
                      FunctionButton(
                        text: 'Add House',
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {

                            if (const ListEquality().equals(ref.watch(imageNameProvider), ['Select images'])) {
                              SnackBars.showErrorSnackBar(context,
                                  'Select at least one image of the house');
                            }
                            else {
                              List<String>? urls = await imagePickerService
                                  .uploadFiles(ref.watch(imageFileProvider));
                              try {
                                String message = await ref.watch(
                                    firebaseServices).addHouseListing(
                                  houseNameController.text,
                                  selectedLocation,
                                  int.parse(priceController.text),
                                  selectedSize,
                                  urls,
                                  descController.text,
                                  selectedAmenities.value,
                                  bookingStatus == 'Booked' ? true : false,
                                );
                                if (!context.mounted) return;
                                if (message == 'exists') {
                                  SnackBars.showInfoSnackBar(context,
                                      'House ${houseNameController
                                          .text} already exists');
                                }
                                else {
                                  SnackBars.showSuccessSnackBar(context,
                                      'House ${houseNameController
                                          .text} added successfully');
                                }
                              } catch (e) {
                                logger.e(e);
                                if(!context.mounted) return;
                                SnackBars.showErrorSnackBar(context,
                                    'An error occurred trying to add House ${houseNameController
                                        .text}. Please try again');
                              }
                            }
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
          ),
        ),
      ),
    );
  }
}
