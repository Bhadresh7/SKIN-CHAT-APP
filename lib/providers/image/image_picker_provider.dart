import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skin_chat_app/constants/app_db_constants.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/services/hive_service.dart';

class ImagePickerProvider extends ChangeNotifier {
  File? selectedImage;

  final ImagePicker _picker = ImagePicker();

  Future<String> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      debugPrint("Selected Image Path: ${selectedImage!.path}");
      notifyListeners();
      return AppStatus.kSuccess;
    } else {
      return AppStatus.kFailed;
    }
  }

  // Future<File?> compressImage(File imageFile) async {
  //   final filePath = imageFile.absolute.path;
  //   final lastIndex = filePath.lastIndexOf(".");
  //   final newPath = "${filePath.substring(0, lastIndex)}_compressed.jpg";
  //
  //   // Size before compression
  //   final beforeSize = imageFile.lengthSync();
  //   print("📦 Original size: ${beforeSize / 1024} KB");
  //
  //   var result = await FlutterImageCompress.compressAndGetFile(
  //     filePath,
  //     newPath,
  //     quality: 20,
  //     minWidth: 500,
  //     minHeight: 500,
  //     autoCorrectionAngle: true,
  //   );
  //
  //   if (result != null) {
  //     final compressedFile = File(result.path);
  //     final afterSize = compressedFile.lengthSync();
  //     print("📉 Compressed size: ${afterSize / 1024} KB");
  //     return compressedFile;
  //   } else {
  //     print("❌ Compression failed.");
  //     return null;
  //   }
  // }
  Future<File?> compressImage(File imageFile) async {
    final filePath = imageFile.absolute.path;
    final lastIndex = filePath.lastIndexOf(".");
    final newPath = "${filePath.substring(0, lastIndex)}_compressed.jpg";

    final beforeSize = imageFile.lengthSync();
    print("📦 Original size: ${beforeSize / 1024} KB");

    int quality = 90;
    int minWidth = 1000;
    int minHeight = 1000;

    File? finalCompressedFile;

    while (quality >= 10) {
      var result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        newPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
        autoCorrectionAngle: true,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        final compressedFile = File(result.path);
        final afterSize = compressedFile.lengthSync();
        final afterSizeKB = afterSize / 1024;

        print(
            "🔁 Quality: $quality, Size: ${afterSizeKB.toStringAsFixed(2)} KB");

        if (afterSizeKB <= 50 && afterSizeKB >= 30) {
          print(
              "✅ Compressed successfully to ${afterSizeKB.toStringAsFixed(2)} KB");
          return compressedFile;
        } else {
          finalCompressedFile = compressedFile; // Fallback
        }
      }

      // Reduce quality and dimensions for further attempts
      quality -= 10;
      minWidth = (minWidth * 0.8).toInt();
      minHeight = (minHeight * 0.8).toInt();
    }

    print("⚠️ Could not compress within 30–50 KB. Closest attempt returned.");
    return finalCompressedFile;
  }

  bool isUploading = false;

  Future<String?> uploadImageToFirebase(String userId) async {
    if (selectedImage == null) return AppStatus.kFailed;

    isUploading = true;
    notifyListeners();

    try {
      // Step 1: Compress image
      File? compressedImage = await compressImage(selectedImage!);
      if (compressedImage == null) {
        isUploading = false;
        notifyListeners();
        return AppStatus.kFailed;
      }

      // Step 2: Upload to Firebase Storage
      String filePath = "profile_images/$userId.jpg";
      Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
      UploadTask uploadTask = storageRef.putFile(compressedImage);

      // Optional: Show upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print("📤 Upload Progress: ${(progress * 100).toStringAsFixed(2)}%");
      });

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      print("ID OF THE USER TO UPDATE )))))))))))))))$userId");

      // Step 3: Check both collections in parallel
      final usersRef = FirebaseFirestore.instance
          .collection(AppDbConstants.kUserCollection)
          .doc(userId);
      final superAdminsRef = FirebaseFirestore.instance
          .collection(AppDbConstants.kSuperAdminCollection)
          .doc(userId);

      final results = await Future.wait([usersRef.get(), superAdminsRef.get()]);

      final usersDoc = results[0];
      final superAdminsDoc = results[1];

      DocumentReference? docToUpdate;
      if (usersDoc.exists) {
        docToUpdate = usersRef;
      } else if (superAdminsDoc.exists) {
        docToUpdate = superAdminsRef;
      } else {
        print(
            "❌ User not found in either 'users' or 'super_admins' collection.");
        return "";
      }

      await HiveService.updateUserImageInHive(downloadUrl);
      // Step 4: Update Firestore document
      await docToUpdate.update({"imageUrl": downloadUrl});
      print("✅ imageUrl updated for $userId: $downloadUrl");

      return downloadUrl;
    } catch (e) {
      print("❌ Error uploading image: $e");
      return "";
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  void clear() {
    selectedImage = null;
    notifyListeners();
  }
}
