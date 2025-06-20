import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:skin_chat_app/models/chat_message.dart';
import 'package:skin_chat_app/models/meta_model.dart';
import 'package:skin_chat_app/services/hive_service.dart';

class ChatService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("chats");

  UploadTask? _currentUploadTask;

  UploadTask? get currentUploadTask => _currentUploadTask;

  // final _messageController = StreamController<List<types.Message>>.broadcast();
  // StreamSubscription<DatabaseEvent>? _messageSubscription;

  // Stream<List<types.Message>> get messagesStream => _messageController.stream;

  // final _messageController =
  //     StreamController<List<types.CustomMessage>>.broadcast();
  // StreamSubscription<DatabaseEvent>? _messageSubscription;
  //
  // Stream<List<types.CustomMessage>> get messagesStream =>
  //     _messageController.stream;
  //
  // void initMessageListener() {
  //   _messageSubscription =
  //       _databaseRef.orderByChild("ts").onValue.listen((event) {
  //     if (event.snapshot.value == null) {
  //       _messageController.add([]);
  //       return;
  //     }
  //
  //     final rawData = event.snapshot.value;
  //     if (rawData is! Map) {
  //       _messageController.add([]);
  //       return;
  //     }
  //
  //     final messages = rawData.entries
  //         .map((entry) {
  //           final messageData = entry.value;
  //           if (messageData is! Map) return null;
  //
  //           final author = types.User(
  //             id: messageData["id"].toString(),
  //             firstName: messageData["name"]?.toString() ?? "Unknown",
  //           );
  //
  //           final timestamp =
  //               messageData["ts"] ?? DateTime.now().millisecondsSinceEpoch;
  //           final msg = messageData["metadata"];
  //           if (msg is! Map) return null;
  //
  //           return types.CustomMessage(
  //             id: entry.key,
  //             author: author,
  //             createdAt: timestamp,
  //             metadata: {
  //               "text": msg["text"],
  //               "url": msg["url"],
  //               "img": msg["img"],
  //             },
  //           );
  //         })
  //         .whereType<types.CustomMessage>()
  //         .toList();
  //
  //     messages.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
  //     _messageController.add(messages);
  //   });
  // }
  //
  // void dispose() {
  //   _messageSubscription?.cancel();
  //   _messageController.close();
  // }

  // void initMessageListener() {
  //   _messageSubscription =
  //       _databaseRef.orderByChild("ts").onValue.listen((event) {
  //     if (event.snapshot.value == null) {
  //       _messageController.add([]);
  //       return;
  //     }
  //
  //     final rawData = event.snapshot.value;
  //     if (rawData is! Map) {
  //       _messageController.add([]);
  //       return;
  //     }
  //
  //     final messages = rawData.entries
  //         .map((entry) {
  //           final messageData = entry.value;
  //           if (messageData is! Map) return null;
  //
  //           final author = types.User(
  //             id: messageData["id"].toString(),
  //             firstName: messageData["name"]?.toString() ?? "Unknown",
  //           );
  //
  //           final timestamp =
  //               messageData["ts"] ?? DateTime.now().millisecondsSinceEpoch;
  //           final msg = messageData["metadata"];
  //           if (msg is! Map) return null;
  //
  //           return types.CustomMessage(
  //             id: entry.key,
  //             author: author,
  //             createdAt: timestamp,
  //             metadata: {
  //               "text": msg["text"],
  //               "url": msg["url"],
  //               "img": msg["img"],
  //             },
  //           );
  //         })
  //         .whereType<types.Message>()
  //         .toList();
  //
  //     messages.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
  //     _messageController.add(messages);
  //   });
  // }

  // void dispose() {
  //   _messageSubscription?.cancel();
  //   _messageController.close();
  // }

  // Stream<List<types.Message>> getMessagesStream() {
  //   return _databaseRef.orderByChild("ts").onValue.map((event) {
  //     if (event.snapshot.value == null) return [];
  //
  //     final rawData = event.snapshot.value;
  //     if (rawData is! Map) return [];
  //
  //     final messages = rawData.entries
  //         .map((entry) {
  //           final messageData = entry.value;
  //           if (messageData is! Map) return null;
  //
  //           final author = types.User(
  //             id: messageData["id"].toString(),
  //             firstName: messageData["name"]?.toString() ?? "Unknown",
  //           );
  //
  //           final timestamp =
  //               messageData["ts"] ?? DateTime.now().millisecondsSinceEpoch;
  //
  //           final msg = messageData["metadata"];
  //           if (msg is! Map) return null;
  //
  //           return types.CustomMessage(
  //             id: entry.key,
  //             author: author,
  //             createdAt: timestamp,
  //             metadata: {
  //               "text": msg["text"],
  //               "url": msg["url"],
  //               "img": msg["img"],
  //             },
  //           );
  //         })
  //         .whereType<types.Message>()
  //         .toList();
  //
  //     messages.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
  //     return messages;
  //   });
  // }

  ///delete messages from database
  Future<void> deleteMessage({required String messageKey}) async {
    try {
      print("Attempting to delete message with key: $messageKey");
      await _databaseRef.child(messageKey).remove();

      print("FROM CHAT SERVICE DELETE FUNCTION  !!!!!!!!!!!!!!!");
    } catch (e) {
      print("Error deleting message: $e");
    }
  }

  ///send messages to firebase-realtime database
  Future<void> sendMessageToRTDB({
    required ChatMessage message,
  }) async {
    DatabaseReference ref = _databaseRef.child(message.id);
    await ref.set(
      {
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

      final customMessage = MetaModel(img: imageUrl);
      final chatMessage = ChatMessage(
        author: types.User(id: userId),
        metaModel: customMessage,
        id: userId,
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
        final customMessage = MetaModel(img: imageUrl, text: caption);
        final chatMessage = ChatMessage(
          author: types.User(id: userId),
          metaModel: customMessage,
          id: userId,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
        // Save URL to Realtime DB (or Firestore depending on your implementation)
        await sendMessageToRTDB(message: chatMessage);
      } else {
        final customMessage = MetaModel(
          img: imageUrl,
        );
        final chatMessage = ChatMessage(
          author: types.User(id: userId),
          metaModel: customMessage,
          id: userId,
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

  Future<void> addMessagesToLocalStorage({required ChatMessage message}) async {
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
}
