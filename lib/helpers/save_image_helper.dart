import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saver_gallery/saver_gallery.dart';

class SaveImageHelper {
  static Future<File> saveImageToGallery({required String url}) async {
    final dio = Dio();

    // Generate a unique filename based on the URL hash
    final String fileName = '${md5.convert(utf8.encode(url))}.jpg';

    // Get downloads directory
    final directory = await getDownloadsDirectory();
    if (directory == null) {
      throw Exception("Unable to access download directory");
    }

    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    // ✅ If the file already exists locally, assume it's saved in gallery too
    if (await file.exists()) {
      debugPrint('Image already exists at: $filePath');
      return file;
    }

    try {
      // Download the image bytes
      final response = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final Uint8List imageBytes = Uint8List.fromList(response.data!);

      // Save to local file
      await file.writeAsBytes(imageBytes);

      // ✅ Save to gallery (with skipIfExists: true)
      final result = await SaverGallery.saveImage(
        imageBytes,
        quality: 100,
        fileName: fileName.replaceAll('.jpg', ''),
        skipIfExists: true,
        androidRelativePath: "Pictures/SKIN_CHATS_IMAGE/SKIN_CHATS",
      );

      if (!result.isSuccess) {
        debugPrint("Image save to gallery failed: ${result.errorMessage}");
        throw Exception("Failed to save image to gallery");
      }

      return file;
    } catch (e) {
      debugPrint('Error saving image: $e');
      rethrow;
    }
  }
}

// save_image_helper.dart
// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:saver_gallery/saver_gallery.dart';
//
// class SaveImageHelper {
//   /// Saves a file to gallery and returns the File (you can use this for uploading).
//   static Future<File?> saveAndReturnFile(File file) async {
//     try {
//       final Uint8List imageBytes = await file.readAsBytes();
//       final fileName = basename(file.path).replaceAll('.jpg', '');
//
//       // Save to gallery
//       final success = await SaverGallery.saveImage(
//         imageBytes,
//         quality: 100,
//         fileName: fileName,
//         skipIfExists: true,
//         androidRelativePath: "Pictures/SKIN_CHATS_IMAGE/SKIN_CHATS",
//       );
//
//       if (success != true) {
//         print('❌ Failed to save image to gallery');
//         return null;
//       }
//
//       // Optional: Copy to app directory for Firebase upload
//       final Directory appDocDir = await getApplicationDocumentsDirectory();
//       final String newPath = '${appDocDir.path}/$fileName.jpg';
//       final File newFile = await file.copy(newPath);
//
//       return newFile;
//     } catch (e) {
//       print("❌ Error saving image to gallery: $e");
//       return null;
//     }
//   }
// }
