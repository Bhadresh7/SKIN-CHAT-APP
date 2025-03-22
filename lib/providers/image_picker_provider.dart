import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerProvider extends ChangeNotifier {
  File? selectedImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<String?> uploadImageToFirebase(String userId) async {
    if (selectedImage == null) return null;

    try {
      // Create a storage reference
      String filePath = "profile_images/$userId.jpg";
      Reference storageRef = FirebaseStorage.instance.ref().child(filePath);

      // Upload the file
      UploadTask uploadTask = storageRef.putFile(selectedImage!);
      TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection("users").doc(userId).update({
        "imageUrl": downloadUrl,
      });
      // Store URL in Realtime Database
      await FirebaseDatabase.instance
          .ref()
          .child("chats")
          .child(userId)
          .update({"imageUrl": downloadUrl});

      return downloadUrl;
    } catch (e) {
      print("❌ Error uploading image: $e");
      return null;
    }
  }
}
