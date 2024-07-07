import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart';
import 'package:image_tagging_application/csv_service.dart';
import 'package:image_tagging_application/tagging_service.dart';

void main() async {
  final TaggingService taggingService = TaggingService();
  await taggingService.initialize();
  bool loopFinished = false;
  while (!loopFinished) {
    try {
      for (var i = 0; i < taggingService.imagePaths.length; i++) {
        if (await CSVService.isImageInCsv(taggingService.imagePaths[i], 'existing.csv')) {
          continue;
        }
        try {
          await taggingService.getKeywords(taggingService.getFilesFromImagePaths(taggingService.imagePaths[i]));
        } catch (e) {
          print("Decoding from json is failed! Skipping this image!");
          continue;
        }
      }
      loopFinished = true;
    } on GenerativeAIException catch (_) {
      print("Sleeping for 30 seconds");
      await CSVService.addOutputToExisting();
      await Future.delayed(Duration(seconds: 30));
    } on ClientException catch (_) {
      print("Sleeping for 30 seconds");
      await CSVService.addOutputToExisting();
      await Future.delayed(Duration(seconds: 30));
    }
  }
}
