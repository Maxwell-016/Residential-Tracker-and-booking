
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class ImagePickerService{

  Future<dynamic> pickImages() async{
    ImagePicker picker = ImagePicker();
    Logger logger = Logger();
    final List<XFile?> pickedFiles = await picker.pickMultiImage(limit: 5,) ;
    List <Uint8List> imageBytes = [];
    List<String> names = [];
    for(var file in pickedFiles){
      if(file != null){
        final bytes = await file.readAsBytes();
        imageBytes.add(bytes);
        names.add(file.name);
      }
      else{
        logger.i('No image picked');
      }
    }
    logger.i(imageBytes);
    logger.i(names);
    return[imageBytes];
    }
}