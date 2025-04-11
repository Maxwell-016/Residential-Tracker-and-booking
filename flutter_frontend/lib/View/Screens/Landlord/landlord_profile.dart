import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/utils/validator.dart';
import 'package:flutter_frontend/View/Components/function_button.dart';
import 'package:flutter_frontend/View/Components/landlord_side_nav.dart';
import 'package:flutter_frontend/View/Components/snackbars.dart';
import 'package:flutter_frontend/View/Components/text_field.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_frontend/services/image_picker_service.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../View-Model/utils/app_colors.dart';
import '../../../View-Model/view_model.dart';
import '../../../constants.dart';
import '../../Components/SimpleAppBar.dart';

final profilePhotoNameProvider =
    StateProvider<List<String>>((ref) => ['Select images']);
final profilePhotoFileProvider = StateProvider<List<Uint8List>>((ref) => []);
final profileUrl = StateProvider<String>((ref) => '');

class LandlordProfile extends HookConsumerWidget {
  const LandlordProfile({
    super.key,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
  });

  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    Logger logger = Logger();
    final firebaseServicesProvider = ref.watch(firebaseServices);
    ImagePickerService imagePickerService = ImagePickerService();

    final landlordDetails = useState<Map<String, dynamic>>({});
    final isLoading = useState<bool>(true);

    logger.i(landlordDetails.value);

    TextEditingController nameController = useTextEditingController();
    FocusNode nameFocus = useFocusNode();
    TextEditingController emailController = useTextEditingController();
    FocusNode emailFocus = useFocusNode();
    TextEditingController phoneController = useTextEditingController();
    FocusNode phoneFocus = useFocusNode();

    useEffect(() {
      Future.microtask(() async {
        final profile = await firebaseServicesProvider.getLandlordProfile();
        if (profile != null && profile.isNotEmpty) {
          landlordDetails.value = profile;
          isLoading.value = false;
          ref.read(houseLocationProvider.notifier).state =
              landlordDetails.value['Location'] ?? 'kakamega town';
          nameController.text = landlordDetails.value['Name'];
          emailController.text = landlordDetails.value['Email'];
          phoneController.text = landlordDetails.value['Phone Number'];
        }
        isLoading.value = false;
      });
      return null;
    }, []);

    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color borderColor =
        isDark ? AppColors.lightThemeBackground : AppColors.darkThemeBackground;
    final deviceWidth = MediaQuery.of(context).size.width;
    double width = deviceWidth > 800 ? deviceWidth / 2.2 : deviceWidth / 1.1;

    bool isVerified = ref.watch(verifiedLandlord);

    String selectedLocation = ref.watch(houseLocationProvider);

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

    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   iconTheme: IconThemeData(size: 30.0),
        // ),

        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: App_Bar(
              changeTheme: changeTheme,
              changeColor: changeColor,
              colorSelected: colorSelected,
              title: ""),
        ),

        drawer: LandlordSideNav(),
        body: isLoading.value
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Center(
                  child: Card(
                    elevation: 5,
                    shadowColor: isDark ? Colors.white : Colors.black,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 20.0,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                List<Uint8List> imageFiles = [];
                                List<String> imageNames = [];

                                final images =
                                    await imagePickerService.pickImages();

                                if (images != null && images.isNotEmpty) {
                                  for (final image in images) {
                                    imageFiles.add(image.bytes);
                                    imageNames.add(image.name);
                                  }
                                }

                                List<String>? urls = await imagePickerService
                                    .uploadFiles(imageFiles);
                                String profilePhoto = (urls != null &&
                                        urls.isNotEmpty)
                                    ? urls[0]
                                    : landlordDetails.value['Profile Photo'] ??
                                        '';

                                ref.read(profileUrl.notifier).state =
                                    profilePhoto;
                                logger.i(ref.watch(profileUrl));
                              },
                              child: CircleAvatar(
                                radius: 80.0,
                                backgroundImage: ref
                                        .watch(profileUrl)
                                        .isNotEmpty
                                    ? NetworkImage(ref.watch(profileUrl))
                                        as ImageProvider
                                    : landlordDetails.value['Profile Photo'] !=
                                                null &&
                                            landlordDetails
                                                .value['Profile Photo']
                                                .isNotEmpty
                                        ? NetworkImage(landlordDetails
                                                .value['Profile Photo'])
                                            as ImageProvider
                                        : null,
                                child: (ref.watch(profileUrl).isEmpty &&
                                        (landlordDetails
                                                    .value['Profile Photo'] ==
                                                null ||
                                            landlordDetails
                                                .value['Profile Photo']
                                                .isEmpty))
                                    ? Icon(Icons.person_add_alt, size: 50.0)
                                    : null,
                              ),
                            ),
                            MyTextField(
                                label: 'Name',
                                placeHolder: 'Enter your name',
                                controller: nameController,
                                icon: Icon(Icons.drive_file_rename_outline),
                                fieldValidator: Validators.fieldValidator,
                                focusNode: nameFocus,
                                width: width),
                            MyTextField(
                                label: 'Email',
                                placeHolder: 'Enter your email',
                                controller: emailController,
                                icon: Icon(Icons.email_outlined),
                                fieldValidator: Validators.emailValidator,
                                focusNode: emailFocus,
                                width: width),
                            MyTextField(
                                label: 'Phone',
                                placeHolder: 'Enter your phone number',
                                controller: phoneController,
                                icon: Icon(Icons.phone_outlined),
                                fieldValidator: Validators.intFieldValidator,
                                focusNode: phoneFocus,
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
                            isVerified
                                ? Container(
                                    width: width,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: AppColors.totalListings,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(child: Text('Verified')),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () async {
                                      try {
                                        await firebaseServicesProvider
                                            .sendEmailVerification();
                                        if (!context.mounted) return;
                                        SnackBars.showInfoSnackBar(context,
                                            'An email verification link has been sent to your email. Click the link to be verified');
                                      } catch (e) {
                                        logger.e(e);
                                        SnackBars.showErrorSnackBar(
                                            context, 'An error occurred $e');
                                      }
                                    },
                                    child: Container(
                                      width: width,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: AppColors.booked),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child:
                                            Center(child: Text('Verify Now')),
                                      ),
                                    ),
                                  ),
                            firebaseServicesProvider.isUpdatingLandlordProfile
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : FunctionButton(
                                    text: 'Update Profile',
                                    onPressed: () async {
                                      if (formKey.currentState!.validate()) {
                                        try {
                                          String profile =
                                              ref.watch(profileUrl);

                                          String? message =
                                              await firebaseServicesProvider
                                                  .createLandlordProfile(
                                                      ref,
                                                      nameController.text,
                                                      emailController.text,
                                                      phoneController.text,
                                                      ref.watch(
                                                          houseLocationProvider),
                                                      profile);
                                          if (!context.mounted) return;
                                          if (message == null) {
                                            SnackBars.showSuccessSnackBar(
                                                context,
                                                'Profile Updated successfully');
                                          }
                                          if (message == 'No Change') {
                                            SnackBars.showInfoSnackBar(context,
                                                'There\'s no change on your profile');

                                          }
                                        } catch (e) {
                                          firebaseServicesProvider.setIsUpdatingLandlordProfile(false);
                                          logger.e(e);
                                          SnackBars.showErrorSnackBar(context,
                                              'An error occurred trying to update your profile. Please try again');
                                        }
                                      }
                                    },
                                    btnColor: AppColors.deepBlue,
                                    width: width,
                                  ),
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
