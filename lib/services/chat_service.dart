import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:skin_chat_app/models/chat_message_model.dart';
import 'package:skin_chat_app/models/meta_model.dart';
import 'package:skin_chat_app/services/hive_service.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("chats");

  UploadTask? _currentUploadTask;

  UploadTask? get currentUploadTask => _currentUploadTask;

  ///delete messages from database
  Future<void> deleteMessage({required String messageId}) async {
    try {
      print("DELETE FUNCTION $messageId");
      await _databaseRef.child(messageId).remove();

      print("FROM CHAT SERVICE DELETE FUNCTION  !!!!!!!!!!!!!!!");
    } catch (e) {
      print("Error deleting message: $e");
    }
  }

  ///send messages to firebase-realtime database
  Future<void> sendMessageToRTDB({
    required ChatMessageModel message,
  }) async {
    DatabaseReference ref = _databaseRef.child(message.id);
    await ref.set(
      {
        "id": message.author.id,
        "name": message.author.firstName,
        "metadata": message.metaModel.toJson(),
        "ts": ServerValue.timestamp,
      },
    );
  }

  ///Method to Upload images to firebase-store and store
  ///the url in realtime-database
  Future<String> uploadImageAndSend(
    File imageFile,
    String userId,
    void Function(double)? onProgress,
  ) async {
    final messageId = Uuid().v4();
    final storageRef = FirebaseStorage.instance
        .ref()
        .child("chat_images/$userId/$messageId.jpg");

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

      final customMessage = MetaModel(img: imageUrl);
      final chatMessage = ChatMessageModel(
        author: types.User(
            id: userId, firstName: HiveService.getCurrentUser()?.username),
        metaModel: customMessage,
        id: messageId,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      // Save URL to Realtime DB (or Firestore depending on your implementation)
      await sendMessageToRTDB(message: chatMessage);

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
    void Function(double)? onProgress,
  ) async {
    final messageId = Uuid().v4();
    final storageRef = FirebaseStorage.instance
        .ref()
        .child("chat_images/$userId/$messageId.jpg");

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
        final customMessage = MetaModel(img: imageUrl, text: caption);
        final chatMessage = ChatMessageModel(
          author: types.User(
              id: userId, firstName: HiveService.getCurrentUser()?.username),
          metaModel: customMessage,
          id: Uuid().v4(),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
        // Save URL to Realtime DB (or Firestore depending on your implementation)
        await sendMessageToRTDB(message: chatMessage);
      } else {
        final customMessage = MetaModel(
          img: imageUrl,
        );
        final chatMessage = ChatMessageModel(
          author: types.User(
              id: userId, firstName: HiveService.getCurrentUser()?.username),
          metaModel: customMessage,
          id: Uuid().v4(),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
        // Save URL to Realtime DB (or Firestore depending on your implementation)
        await sendMessageToRTDB(message: chatMessage);
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

  /// FUNCTIONS TO SHOW THE MESSAGES WHEN THE USER IS OFFLINE

  Future<void> addMessagesToLocalStorage(
      {required ChatMessageModel message}) async {
    try {
      await HiveService.saveMessage(message: message);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteMessagesFromLocalStorage({
    required String messageId,
  }) async {
    try {
      await HiveService.deleteMessage(messageId);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteImageFromStorage(
      {required String messageId, required String userId}) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("chat_images/$userId/$messageId.jpg");
      await storageRef.delete();
    } catch (e) {
      print(e.toString());
    }
  }
}
