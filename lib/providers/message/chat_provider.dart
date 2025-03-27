import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../services/message_service.dart';
import '../auth/my_auth_provider.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider() {
    print("I'm Initilized");
  }
  final ChatService _chatService = ChatService();
  List<types.Message> _messages = [];

  List<types.Message> get messages => _messages;

  // listenForMessages() {
  //   _chatService.getMessagesStream().listen(
  //     (newMessages) {
  //       _messages = newMessages;
  //       notifyListeners();
  //     },
  //   );
  // }

  Stream<List<types.Message>> get messagesStream =>
      _chatService.getMessagesStream();

  Future<void> sendMessage(
      types.PartialText message, MyAuthProvider authProvider) async {
    try {
      final newMessage = types.TextMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        author: types.User(
          id: authProvider.uid,
          firstName: authProvider.userName ?? authProvider.formUserName,
          // imageUrl: imageProvider.imgUrl ?? "hello there",
        ),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        text: message.text,
      );

      _messages.insert(0, newMessage);

      await _chatService.sendMessage(message.text, authProvider.uid,
          authProvider.userName ?? authProvider.formUserName
          // imageProvider.imgUrl ?? "",
          );
      // print(imageProvider.selectedImage);

      print("🔥🔥🔥 Message Sent: ${message.text} 🔥🔥🔥");
    } catch (e) {
      print("🔥🔥🔥 Error Sending Message: ${e.toString()} 🔥🔥🔥");
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteMessage(String messageKey) async {
    await _chatService.deleteMessage(messageKey: messageKey);

    // Remove from local list and notify UI
    messages.removeWhere((msg) => msg.id == messageKey);
    notifyListeners();
  }
}
