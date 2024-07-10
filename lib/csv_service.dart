import 'dart:io';

abstract class CSVService {
  static void saveMetadataToCSV(
      {required String filename,
      required String title,
      required String category,
      required List<String> keywords}) async {
    String csvContent = '"$filename","$title","${keywords.join(', ')}","$category"\n';

    String directory = Directory.current.path;

    File file = File('$directory/output.csv');
    if (!await file.exists()) {
      csvContent = 'Filename,Title,Keywords,Category\n$csvContent';
    }
    await file.writeAsString(csvContent, mode: FileMode.append);

    print('$filename saved to output.csv');
  }

  static Future<bool> isImageInCsv(String imagePath, String csvPath) async {
    final csvFile = File(csvPath);

    if (!await csvFile.exists()) return false;

    final lines = await csvFile.readAsLines();

    String imageName = "image${imagePath.split('/').last.replaceAll(".png", ".jpeg")}";
    bool found = false;

    for (var line in lines) {
      if (line.split(',')[0].replaceAll('"', "") == imageName) {
        found = true;
        break;
      }
    }
    return found;
  }

  static addOutputToExisting() async {
    final outputFile = File("output.csv");
    final existingFile = File('existing.csv');

    if (!await outputFile.exists()) {
      print("Output file does not exist.");
      return;
    }

    try {
      List<String> outputLines = await outputFile.readAsLines();
      if (outputLines.isNotEmpty && outputLines[0].startsWith("Filename")) {
        outputLines.removeAt(0);
      }

      IOSink sink = existingFile.openWrite(mode: FileMode.append);
      if (!(await existingFile.exists())) {
        sink.writeln("Filename,Title,Keywords,Category");
      }
      for (String line in outputLines) {
        sink.writeln(line);
      }
      await sink.close();

      await outputFile.delete();
    } catch (e) {
      print("Error appending or deleting files: $e");
    }
  }

  initialize() async {
    final outputFile = File("output.csv");
    final existingFile = File("output.csv");
    if (!await outputFile.exists()) {
      await outputFile.create();
      await outputFile.writeAsString("Filename,Title,Keywords,Category\n");
    }

    if (!await existingFile.exists()) {}
  }
}
