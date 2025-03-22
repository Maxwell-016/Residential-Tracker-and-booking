import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/utils/validator.dart';
import 'package:flutter_frontend/View-Model/view_model.dart';
import 'package:flutter_frontend/View/Components/side_nav.dart';
import 'package:flutter_frontend/View/Components/text_field.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../View-Model/utils/app_colors.dart';

class AddHouse extends HookConsumerWidget {
  final double width;
  const AddHouse({
    super.key,
    required this.width,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController houseNameController = useTextEditingController();
    FocusNode houseNameFocus = useFocusNode();
    TextEditingController priceController = useTextEditingController();
    FocusNode priceFocus = useFocusNode();
    TextEditingController unitsController = useTextEditingController();
    FocusNode unitsFocus = useFocusNode();
    TextEditingController descController = useTextEditingController();
    FocusNode descFocus = useFocusNode();
    String selectedSize = ref.watch(selectedHouseSize);

    final amenities = useState<Map<String, bool>>({
      'Wi-Fi': false,
      'Parking': false,
      'Gym': false,
      'Security': false,
      'Water': false,
      'Electricity': false,
    });
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
        drawer: SideNav(),
        body: SingleChildScrollView(
          child: Center(
              child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
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
                      fieldValidator: Validators.fieldValidator,
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
                            ref.read(selectedHouseSize.notifier).state = value!;
                          },
                        ),
                      ),
                    ],
                  ),
                  MyTextField(
                      label: 'Units',
                      placeHolder: 'Number of units available',
                      controller: unitsController,
                      icon: Icon(Icons.numbers),
                      fieldValidator: Validators.fieldValidator,
                      focusNode: unitsFocus,
                      width: width),
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
                          border: Border.all(color:borderColor,width: 1),
                          borderRadius: BorderRadius.circular(10.0)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Wrap(
                              spacing: 40.0,
                              runSpacing: 20.0,
                              children: amenities.value.entries.map((entry) {
                                return SizedBox(
                                  width: width / 3,
                                  child: CheckboxListTile(
                                      hoverColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      title: Text(entry.key),
                                      value: entry.value,
                                      onChanged: (value) {
                                        amenities.value = {
                                          ...amenities.value,
                                          entry.key: value ?? false,
                                        };
                                      }),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  //image picker
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }
}
