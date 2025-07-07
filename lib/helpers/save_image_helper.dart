// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:crypto/crypto.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:saver_gallery/saver_gallery.dart';
//
// class SaveImageHelper {
//   static Future<File> saveImageToGallery({required String url}) async {
//     final dio = Dio();
//
//     // Generate a unique file name based on image URL
//     final String fileName = '${md5.convert(utf8.encode(url))}.jpg';
//
//     // Request permissions
//     if (Platform.isAndroid) {
//       final androidStatus = await Permission.photos.request();
//       if (!androidStatus.isGranted) {
//         throw Exception("Photo permission not granted on Android");
//       }
//     } else if (Platform.isIOS) {
//       final iosStatus = await Permission.photosAddOnly.request();
//       if (!iosStatus.isGranted) {
//         throw Exception("Photo add-only permission not granted on iOS");
//       }
//     }
//
//     // Directory to check and save the file
//     final directory = await getDownloadsDirectory();
//     if (directory == null) {
//       throw Exception("Unable to access download directory");
//     }
//
//     final filePath = '${directory.path}/$fileName';
//     final file = File(filePath);
//
//     // ✅ Check if file already exists
//     if (await file.exists()) {
//       debugPrint('Image already exists at: $filePath');
//       return file;
//     }
//
//     // Download the image
//     final response = await dio.get<List<int>>(
//       url,
//       options: Options(responseType: ResponseType.bytes),
//     );
//
//     final Uint8List imageBytes = Uint8List.fromList(response.data!);
//
//     // Write file locally
//     await file.writeAsBytes(imageBytes);
//
//     // Save to gallery
//     final result = await SaverGallery.saveImage(
//       imageBytes,
//       quality: 100,
//       fileName: fileName.replaceAll('.jpg', ''),
//       skipIfExists: true,
//       androidRelativePath: "Pictures/SKIN_CHATS_IMAGE/SKIN_CHATS",
//     );
//
//     if (!result.isSuccess) {
//       throw Exception("Failed to save image to gallery");
//     }
//
//     return file;
//   }
// }
// save_image_helper.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saver_gallery/saver_gallery.dart';

class SaveImageHelper {
  /// Saves a file to gallery and returns the File (you can use this for uploading).
  static Future<File?> saveAndReturnFile(File file) async {
    try {
      final Uint8List imageBytes = await file.readAsBytes();
      final fileName = basename(file.path).replaceAll('.jpg', '');

      // Save to gallery
      final success = await SaverGallery.saveImage(
        imageBytes,
        quality: 100,
        fileName: fileName,
        skipIfExists: true,
        androidRelativePath: "Pictures/SKIN_CHATS_IMAGE/SKIN_CHATS",
      );

      if (success != true) {
        print('❌ Failed to save image to gallery');
        return null;
      }

      // Optional: Copy to app directory for Firebase upload
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String newPath = '${appDocDir.path}/$fileName.jpg';
      final File newFile = await file.copy(newPath);

      return newFile;
    } catch (e) {
      print("❌ Error saving image to gallery: $e");
      return null;
    }
  }
}
