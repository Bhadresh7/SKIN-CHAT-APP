import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("chats");
  UploadTask? _currentUploadTask;

  UploadTask? get currentUploadTask => _currentUploadTask;

  /// Listen for real-time messages
  Stream<List<types.Message>> getMessagesStream() {
    // await Future.delayed(Duration(seconds: 5));

    return _databaseRef.orderByChild("ts").onValue.map((event) {
      if (event.snapshot.value == null) return [];

      final rawData = event.snapshot.value;
      if (rawData is! Map) return [];

      return rawData.entries
          .map(
            (entry) {
              final messageData = entry.value;
              print("-=-=-=-=-=-=-=-$messageData-=-=-=-=");

              if (messageData is! Map) return null;

              final msg = messageData["msg"]?.toString() ?? "";
              final isImage =
                  msg.startsWith("https://firebasestorage.googleapis.com");

              final author = types.User(
                id: messageData["id"].toString(),
                firstName: messageData["name"]?.toString() ?? "Unknown",
              );

              final timestamp =
                  messageData["ts"] ?? DateTime.now().millisecondsSinceEpoch;

              if (isImage) {
                return types.ImageMessage(
                  id: entry.key,
                  author: author,
                  createdAt: timestamp,
                  name: "Image",
                  size: 0,
                  uri: msg,
                  // height: 50,
                  // width: 50,
                );
              } else {
                return types.TextMessage(
                  id: entry.key,
                  author: author,
                  createdAt: timestamp,
                  text: msg,
                );
              }
            },
          )
          .whereType<types.Message>()
          .toList();
    });
  }

  ///delete messages from database
  Future<void> deleteMessage({required String messageKey}) async {
    try {
      await _databaseRef
          .child(messageKey)
          .remove(); // Deletes message from Firebase
    } catch (e) {
      print("Error deleting message: $e");
    }
  }

  ///send messages to firebase-realtime database
  Future<void> sendMessage(
      {required String message,
      required String userId,
      required String userName}) async {
    await _databaseRef.push().set(
      {
        "id": userId,
        "name": userName,
        "msg": message,
        "ts": ServerValue.timestamp,
      },
    );
  }

  ///Method to Upload images to firebase-store and store
  ///the url in realtime-database
  Future<String> uploadImageAndSend(
    File imageFile,
    String userId,
    String userName,
    void Function(double)? onProgress,
  ) async {
    final fileName = "$userName-${DateTime.now().millisecondsSinceEpoch}.jpg";
    final storageRef =
        FirebaseStorage.instance.ref().child("chat_images/$fileName");

    // Assign to _currentUploadTask so we can later cancel it if needed
    _currentUploadTask = storageRef.putFile(imageFile);

    // Listen for progress
    _currentUploadTask!.snapshotEvents.listen((TaskSnapshot snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      if (onProgress != null) {
        onProgress(progress); // progress will be between 0.0 to 1.0
      }
      print("Upload progress: ${(progress * 100).toStringAsFixed(2)}%");
    });

    try {
      TaskSnapshot completedSnapshot = await _currentUploadTask!;
      final imageUrl = await completedSnapshot.ref.getDownloadURL();

      // Save URL to Realtime DB (or Firestore depending on your implementation)
      await sendMessage(
        message: imageUrl,
        userId: userId,
        userName: userName,
      );

      return imageUrl;
    } finally {
      _currentUploadTask = null;
    }
  }

  /// Method to cancel the upload (firebase side)
  void cancelUpload() {
    _currentUploadTask?.cancel();
    _currentUploadTask = null;
  }
}
