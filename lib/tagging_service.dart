import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_tagging_application/csv_service.dart';
import 'package:image_tagging_application/generative_ai_service.dart';

class TaggingService {
  final apiUrl = 'https://api.everypixel.com/v1';
  final dio = Dio();
  static final userID = "***REMOVED***";
  static final secretKey = "***REMOVED***";
  var auth = 'Basic ${base64Encode(utf8.encode('$userID:$secretKey'))}';
  List<String> imagePaths = [];

  getKeywords(File file) async {
    List<String> keywords = [];
    FormData formData = FormData.fromMap({
      "data": await MultipartFile.fromFile(file.path),
    });
    try {
      final response = await dio.post("$apiUrl/keywords",
          options: Options(
            headers: <String, String>{'Authorization': auth},
          ),
          data: formData,
          queryParameters: {"num_keywords": 40});
      for (var i = 0; i < (response.data["keywords"] as List).length; i++) {
        keywords.add((response.data["keywords"] as List)[i]["keyword"]);
      }

      String? paraphrasedTitle = await GenerativeAiService.getTitle(
          file.path.split('/').last.replaceAll(".png", ".jpeg").replaceAll("theyusifahmad_", ""), keywords);

      if (paraphrasedTitle != null) {
        CSVService.saveMetadataToCSV("image${file.path.split('/').last.replaceAll(".png", ".jpeg")}", paraphrasedTitle,
            paraphrasedTitle, keywords);
      }
    } on DioException catch (e) {
      print(e.response);
    }
  }

  initialize({String directory = '/Users/yusifahmadov/Desktop/TOPAZ/raw'}) async {
    await _getImagesInDirectory(directory);
  }

  Future<String?> _getTitle(File file) async {
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path),
    });
    try {
      final response = await dio.post(
        "$apiUrl/image_captioning",
        options: Options(
          headers: <String, String>{'Authorization': auth},
        ),
        data: formData,
      );
      return await response.data["result"]["caption"];
    } on DioException catch (_) {
      return null;
    }
  }

  Future<List<String>> _getImagesInDirectory(String directoryPath) async {
    imagePaths.clear();
    Directory directory = Directory(directoryPath);
    if (!await directory.exists()) {
      throw Exception('Directory not found: $directoryPath');
    }

    List<FileSystemEntity> files = await directory.list().toList();

    for (FileSystemEntity file in files) {
      if (file is File) {
        String ext = file.path.split('.').last.toLowerCase();
        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
          imagePaths.add(file.path);
        }
      }
    }

    return imagePaths;
  }

  File getFilesFromImagePaths(String imagePath) {
    late File tempImage;

    File imageFile = File(imagePath);
    if (imageFile.existsSync()) {
      tempImage = imageFile;
    } else {
      print('Warning: Image file not found at $imagePath');
    }

    return tempImage;
  }
}
