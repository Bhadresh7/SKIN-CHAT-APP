import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:skin_chat_app/models/custom_message_modal.dart';

class ChatService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("chats");
  UploadTask? _currentUploadTask;

  UploadTask? get currentUploadTask => _currentUploadTask;

  Stream<List<types.Message>> getMessagesStream() {
    return _databaseRef.orderByChild("ts").onValue.map((event) {
      if (event.snapshot.value == null) return [];

      final rawData = event.snapshot.value;
      if (rawData is! Map) return [];

      final messages = rawData.entries
          .map((entry) {
            final messageData = entry.value;
            if (messageData is! Map) return null;

            final author = types.User(
              id: messageData["id"].toString(),
              firstName: messageData["name"]?.toString() ?? "Unknown",
            );

            final timestamp =
                messageData["ts"] ?? DateTime.now().millisecondsSinceEpoch;

            final msg = messageData["metadata"];
            if (msg is! Map) return null;

            return types.CustomMessage(
              id: entry.key,
              author: author,
              createdAt: timestamp,
              metadata: {
                "text": msg["text"],
                "url": msg["url"],
                "img": msg["img"],
              },
            );
          })
          .whereType<types.Message>()
          .toList();

      messages.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
      return messages;
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
  Future<void> sendMessage({
    required CustomMessageModal message,
    required String userId,
    required String userName,
    // PreviewDataModal? meta,
  }) async {
    print("FROM SERVICE ))))))))))))))??????????????${message.toJson()}");
    await _databaseRef.push().set(
      {
        "id": userId,
        "name": userName,
        "metadata": message.toJson(),
        "ts": ServerValue.timestamp,
        // "meta": meta?.toJson()
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

      final customMessage = CustomMessageModal(img: imageUrl);

      // Save URL to Realtime DB (or Firestore depending on your implementation)
      await sendMessage(
        message: customMessage,
        userId: userId,
        userName: userName,
      );

      return imageUrl;
    } finally {
      _currentUploadTask = null;
    }
  }

  /// Method to upload an image and send it with a caption text
  /// This handles when a user sends both an image and text together
  Future<String> uploadImageAndSendWithCaption(
    File imageFile,
    String caption,
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

      // First approach: Send image and caption as separate messages

      if (caption.trim().isNotEmpty) {
        final customMessage = CustomMessageModal(img: imageUrl, text: caption);
        await sendMessage(
          message: customMessage,
          userId: userId,
          userName: userName,
        );
      } else {
        final customMessage = CustomMessageModal(img: imageUrl);
        await sendMessage(
          message: customMessage,
          userId: userId,
          userName: userName,
        );
      }

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
