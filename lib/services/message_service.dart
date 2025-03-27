import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("chats");

  /// Listen for real-time messages
  Stream<List<types.Message>> getMessagesStream() {
    return _databaseRef.orderByChild("ts").onValue.map((event) {
      if (event.snapshot.value == null) return [];

      final rawData = event.snapshot.value;
      if (rawData is! Map) return [];

      return rawData.entries
          .map((entry) {
            final messageData = entry.value;
            print("-=-=-=-=-=-=-=-$messageData-=-=-=-=");
            if (messageData is! Map) return null;

            return types.TextMessage(
              id: entry.key,
              author: types.User(
                // imageUrl: _getProfileImageUrl(messageData['id']).toString(),
                id: messageData["id"].toString(),
                firstName: messageData["name"]?.toString() ?? "Unknown",
              ),
              createdAt:
                  messageData["ts"] ?? DateTime.now().millisecondsSinceEpoch,
              text: messageData["msg"]?.toString() ?? "No message",
            );
          })
          .whereType<types.Message>()
          .toList();
    });
  }
  // final DatabaseReference _usersRef = FirebaseDatabase.instance.ref("users");
  //
  // Stream<List<types.Message>> getMessagesStream() {
  //   return _databaseRef.orderByChild("ts").onValue.asyncMap((event) async {
  //     if (event.snapshot.value == null) return [];
  //
  //     final rawData = event.snapshot.value;
  //     if (rawData is! Map) return [];
  //
  //     // Fetch user data once
  //     final usersSnapshot = await _usersRef.get();
  //     final usersData = usersSnapshot.value as Map?;
  //
  //     return rawData.entries
  //         .map((entry) {
  //           final messageData = entry.value;
  //           if (messageData is! Map) return null;
  //
  //           final userId = messageData["id"].toString();
  //           final userProfile = usersData?[userId] as Map?;
  //
  //           return types.TextMessage(
  //             id: entry.key,
  //             author: types.User(
  //               id: userId,
  //               firstName: messageData["name"]?.toString() ?? "Unknown",
  //               imageUrl: userProfile?["profileImg"]?.toString(),
  //             ),
  //             createdAt:
  //                 messageData["ts"] ?? DateTime.now().millisecondsSinceEpoch,
  //             text: messageData["msg"]?.toString() ?? "No message",
  //           );
  //         })
  //         .whereType<types.Message>()
  //         .toList();
  //   });
  // }

  ///delete messages
  Future<void> deleteMessage({required String messageKey}) async {
    try {
      await _databaseRef
          .child(messageKey)
          .remove(); // Deletes message from Firebase
    } catch (e) {
      print("Error deleting message: $e");
    }
  }

  /// Send a new message
  Future<void> sendMessage(String text, String userId, String userName) async {
    await _databaseRef.push().set({
      "id": userId,
      "name": userName,
      "msg": text,
      "ts": ServerValue.timestamp,
      // "img": imageUrl
    });
  }

  ///get image url
  Future<String?> _getProfileImageUrl(String userId) async {
    try {
      String filePath = "profile_images/$userId.jpg";
      Reference ref = FirebaseStorage.instance.ref().child(filePath);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error getting download URL: $e");
      return null;
    }
  }
}
