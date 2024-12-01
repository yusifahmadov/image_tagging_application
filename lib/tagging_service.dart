import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_tagging_application/constant.dart';
import 'package:image_tagging_application/csv_service.dart';
import 'package:image_tagging_application/generative_ai_service.dart';

class TaggingService {
  final apiUrl = 'https://api.everypixel.com/v1';
  final dio = Dio();
  late final String userID;
  late final String secretKey;

  List<String> imagePaths = [];
  TaggingService({required this.userID, required this.secretKey});
  getKeywords(File file) async {
    List<String> keywords = [];
    FormData formData = FormData.fromMap({
      "data": await MultipartFile.fromFile(file.path),
    });
    try {
      final response = await dio.post("$apiUrl/keywords",
          options: Options(
            headers: <String, String>{
              'Authorization': 'Basic ${base64Encode(utf8.encode('$userID:$secretKey'))}'
            },
          ),
          data: formData,
          queryParameters: {"num_keywords": 35});
      for (var i = 0; i < (response.data["keywords"] as List).length; i++) {
        keywords.add((response.data["keywords"] as List)[i]["keyword"]);
      }

      Map<String, String>? data = (await GenerativeAiService.getTitle(
        await file.readAsBytes(),
      ));
      if (data != null) {
        CSVService.saveMetadataToCSV(
            filename: "image${file.path.split('/').last.replaceAll(".png", ".jpeg")}",
            title: data.keys.first,
            category: data.values.first,
            keywords: keywords);
      }
    } on DioException catch (e) {
      logger.e(e.response);
    }
  }

  initialize(
      {String directory = '/Users/yusifahmadov/Documents/Downloads/midjourney'}) async {
    await _getImagesInDirectory(directory);
  }

  @Deprecated(
      "This function is deprecated. Use GenerativeAIService.getTitle for getting titles.")
  Future<String?> getTitle(File file) async {
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path),
    });
    try {
      final response = await dio.post(
        "$apiUrl/image_captioning",
        options: Options(
          headers: <String, String>{
            'Authorization': 'Basic ${base64Encode(utf8.encode('$userID:$secretKey'))}'
          },
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
    print(imagePaths.length);

    return imagePaths;
  }

  File getFilesFromImagePaths(String imagePath) {
    late File tempImage;

    File imageFile = File(imagePath);
    if (imageFile.existsSync()) {
      tempImage = imageFile;
    } else {
      logger.w('Warning: Image file not found at $imagePath');
    }

    return tempImage;
  }
}
