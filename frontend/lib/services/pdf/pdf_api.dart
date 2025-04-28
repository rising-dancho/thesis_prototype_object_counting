import 'dart:io';
import 'dart:typed_data';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:pdf/widgets.dart';

class PdfApi {
  static Future<File> saveFileToDownloads(
      Uint8List bytes, String fileName) async {
    // Get the external storage directory
    final externalDirectory = await getExternalStorageDirectory();

    // Save to the Downloads folder
    final downloadsDirectory =
        '${externalDirectory?.parent.path}/Download'; // Use Downloads folder
    final file = File('$downloadsDirectory/$fileName');

    // Create Downloads folder if it doesn't exist
    final downloadsDir = Directory(downloadsDirectory);
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    // Write bytes to the file
    await file.writeAsBytes(bytes);

    return file;
  }

  static Future<void> openFile(File file) async {
    // Ensure the file path is valid
    if (await file.exists()) {
      print("FILEPATH: ${file.path}");

      final result = await OpenFile.open(file.path);
      print("OpenFile result: $result");

      if (result.type == ResultType.done) {
        print("File opened successfully.");
      } else {
        print("Failed to open file: ${result.message}");
      }
    } else {
      print("File does not exist.");
    }
  }
}
