// import 'package:flutter/cupertino.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
//
// import '../../services/firebase/message_service.dart';
// import '../auth/my_auth_provider.dart';
//
// class ChatProvider extends ChangeNotifier {
//   final ChatService _chatService = ChatService();
//
//   Stream<List<types.Message>> getMessagesStream() {
//     return _chatService.getMessagesStream();
//   }
//
//   Future<void> sendMessage(
//       types.PartialText message, MyAuthProvider authProvider) async {
//     await _chatService.sendMessage(message.text, authProvider.uid);
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';

import '../../services/message_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<types.Message> _messages = [];

  List<types.Message> get messages => _messages;

  listenForMessages() {
    _chatService.getMessagesStream().listen((newMessages) {
      _messages = newMessages;
      notifyListeners();
    });
  }

  Future<void> sendMessage(
      types.PartialText message, MyAuthProvider authProvider) async {
    try {
      await _chatService.sendMessage(
          message.text, authProvider.uid, authProvider.userName);
      notifyListeners();
      print("🔥🔥🔥🔥🔥🔥${message.text}🔥🔥🔥🔥🔥🔥");
    } catch (e) {
      print(e.toString());
    } finally {
      notifyListeners();
    }
  }
}
