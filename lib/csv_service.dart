import 'dart:io';

abstract class CSVService {
  static void saveMetadataToCSV(String filename, String title, String description, List<String> keywords) async {
    String csvContent = '"$filename","$title","$description","${keywords.join(', ')}"\n';

    String directory = Directory.current.path;

    File file = File('$directory/output.csv');
    if (!await file.exists()) {
      csvContent = 'Filename,Title,Description,Keywords\n$csvContent';
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
        sink.writeln("Filename,Title,Description,Keywords");
      }
      for (String line in outputLines) {
        sink.writeln(line);
      }
      await sink.close();

      // Delete the output file
      await outputFile.delete();
    } catch (e) {
      print("Error appending or deleting files: $e");
    }
  }
}
