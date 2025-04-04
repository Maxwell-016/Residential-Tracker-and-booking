import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:file_picker/file_picker.dart';

class ImagePickerService {
  // final String baseUrl =
  //     'https://residential-tracker-and-booking-images.onrender.com';

  Dio dio = Dio();
  Logger logger = Logger();

  Future<List<({Uint8List bytes, String name})>?> pickImages() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: true);
    return result?.files
        .map((file) => (bytes: file.bytes!, name: file.name.split('/').last))
        .toList();
  }

  //upload images
  Future<List<String>?> uploadFiles(List<Uint8List> files) async {
    List<String> uploadedUrls = [];
    String presetName = 'Residential Tracker';
    String name = 'dk10knkfh';
    String resourceType = 'image';
    String uploadUrl =
        'https://api.cloudinary.com/v1_1/$name/$resourceType/upload';

    try {
      for (final file in files) {
        final fileName = 'file-${DateTime.now().millisecondsSinceEpoch}';
        //file.name.split("/").last;
        FormData formData = FormData();

        formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(file, filename: fileName),
          'upload_preset': presetName,
        });

        Response response = await dio.post(uploadUrl, data: formData);
        if (response.statusCode == 200) {
          uploadedUrls.add(response.data['secure_url']);
        }
      }
      return uploadedUrls;
    } catch (e) {
      logger.e('Image upload error : $e');
    }
    return null;
  }
}
