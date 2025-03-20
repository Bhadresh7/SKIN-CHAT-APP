import 'package:firebase_database/firebase_database.dart';
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
            if (messageData is! Map) return null;

            return types.TextMessage(
              id: entry.key,
              author: types.User(
                id: messageData["id"].toString(),
                firstName: messageData["name"]?.toString() ??
                    "Unknown", // Show user name
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

  /// Send a new message
  Future<void> sendMessage(String text, String userId, String userName) async {
    await _databaseRef.push().set({
      "id": userId,
      "name": userName,
      "msg": text,
      "ts": ServerValue.timestamp,
    });
  }
}
