import 'dart:ffi';
import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';

import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class ImagePickerService{

  Future<dynamic> pickImages() async{
    ImagePicker picker = ImagePicker();
    Logger logger = Logger();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery) ;
    if(pickedFile != null){
      Uint8List imageBytes =  (await pickedFile.readAsBytes()) as Uint8List;
      logger.i('imageBytes');
      return[imageBytes];
    }else{
      logger.i('No image picked');
    }
  }
}