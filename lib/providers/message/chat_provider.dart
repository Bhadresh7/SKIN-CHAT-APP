import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';

import '../../services/firebase/message_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<types.Message> _messages = [];

  List<types.Message> get messages => _messages;

  void listenForMessages() {
    _chatService.getMessagesStream().listen((newMessages) {
      _messages = newMessages;
      notifyListeners();
    });
  }

  Future<void> sendMessage(
      types.PartialText message, MyAuthProvider authProvider) async {
    await _chatService.sendMessage(message.text, authProvider.uid);
    notifyListeners();
    print("🔥🔥🔥🔥🔥🔥${message.text}🔥🔥🔥🔥🔥🔥");
  }
}
