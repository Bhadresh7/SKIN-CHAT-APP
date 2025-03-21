import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';

import '../../services/message_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<types.Message> _messages = [];

  // Stream<List<types.Message>> get messageStream =>
  //     _chatService.getMessagesStream();

  List<types.Message> get messages => _messages;

  listenForMessages() {
    _chatService.getMessagesStream().listen(
      (newMessages) {
        _messages = newMessages;
        notifyListeners();
      },
    );
  }

  Future<void> sendMessage(
      types.PartialText message, MyAuthProvider authProvider) async {
    try {
      await _chatService.sendMessage(
        message.text,
        authProvider.uid,
        authProvider.userName ?? authProvider.formUserName,
      );
      // print("🔥🔥🔥 Message Sent: ${message.text} 🔥🔥🔥");
    } catch (e) {
      print("🔥🔥🔥 Error Sending Message: ${e.toString()} 🔥🔥🔥");
    } finally {
      notifyListeners(); // Only call once
    }
  }
}
