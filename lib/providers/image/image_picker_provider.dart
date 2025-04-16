import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skin_chat_app/constants/app_status.dart';

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

  Future<File?> compressImage(File imageFile) async {
    final filePath = imageFile.absolute.path;
    final lastIndex = filePath.lastIndexOf(".");
    final newPath = "${filePath.substring(0, lastIndex)}_compressed.jpg";

    // Size before compression
    final beforeSize = imageFile.lengthSync();
    print("📦 Original size: ${beforeSize / 1024} KB");

    var result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      newPath,
      quality: 50,
      autoCorrectionAngle: true,
    );

    if (result != null) {
      final compressedFile = File(result.path);
      final afterSize = compressedFile.lengthSync();
      print("📉 Compressed size: ${afterSize / 1024} KB");
      return compressedFile;
    } else {
      print("❌ Compression failed.");
      return null;
    }
  }

  bool isUploading = false; // Define a boolean flag

  Future<String?> uploadImageToFirebase(String userId) async {
    if (selectedImage == null) return AppStatus.kFailed;

    isUploading = true;
    notifyListeners();

    try {
      // Compress the image
      File? compressedImage = await compressImage(selectedImage!);
      if (compressedImage == null) {
        isUploading = false;
        notifyListeners();
        return AppStatus.kFailed;
      }

      // Create a storage reference
      String filePath = "profile_images/$userId.jpg";
      Reference storageRef = FirebaseStorage.instance.ref().child(filePath);

      // Upload the compressed file
      UploadTask uploadTask = storageRef.putFile(compressedImage);

      // Show upload progress (optional)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print("📤 Upload Progress: ${(progress * 100).toStringAsFixed(2)}%");
      });

      TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection("users").doc(userId).update({
        "imageUrl": downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      print("❌ Error uploading image: $e");
      return AppStatus.kFailed;
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
