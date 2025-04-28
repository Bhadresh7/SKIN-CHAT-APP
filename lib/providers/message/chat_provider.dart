import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';
import 'package:skin_chat_app/services/message_service.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider() {
    print("I'm Initilized");
  }


  final ChatService _chatService = ChatService();
  final List<types.Message> _messages = [];
  ///controller
  TextEditingController messageController = TextEditingController();

  List<types.Message> get messages => _messages;
  ValueNotifier<double?> uploadProgressNotifier = ValueNotifier(null);

  ///stream of messages from realtime database
  Stream<List<types.Message>> get messagesStream =>
      _chatService.getMessagesStream();

  ///Method to delete messages in the chat
  Future<void> deleteMessage(String messageKey) async {
    await _chatService.deleteMessage(messageKey: messageKey);

    // Remove from local list and notify UI
    messages.removeWhere((msg) => msg.id == messageKey);
    notifyListeners();
  }

  Future<void> sendMessage(dynamic message, MyAuthProvider provider) async {
    try {
      if (message is types.PartialText) {
        final newMessage = types.TextMessage(
          author: types.User(
              id: provider.uid,
              firstName: provider.userName ?? provider.formUserName),
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: message.text,
        );

        await _chatService.sendMessage(
          message: newMessage.text,
          userId: provider.uid,
          userName: provider.userName ?? provider.formUserName,
        );

        _messages.insert(0, newMessage);
      }
    } catch (e) {
      print("❌ Error in sendMessage: $e");
    } finally {
      notifyListeners();
    }
  }

  void clear() {
    messageController.clear();
    notifyListeners();
  }

  ///Method to handle the Image type message

  Future<void> handleImageMessage(
    MyAuthProvider provider,
    File imageFile,
  ) async {
    try {
      uploadProgressNotifier.value = 0.0;

      final imageUrl = await _chatService.uploadImageAndSend(
        imageFile,
        provider.uid,
        provider.userName ?? provider.formUserName,
        (progress) {
          uploadProgressNotifier.value = progress;
        },
      );

      final newMessage = types.ImageMessage(
        author: types.User(id: provider.uid),
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: "${provider.userName ?? provider.formUserName}.jpg",
        size: imageFile.lengthSync(),
        uri: imageUrl,
      );

      _messages.insert(0, newMessage);
      uploadProgressNotifier.value = null;
      notifyListeners();
    } catch (e) {
      print("❌ Error in handleImageMessage: $e");
      uploadProgressNotifier.value = null;
    }
  }

  /// Method to cancel upload
  void cancelUpload() {
    _chatService.cancelUpload();
    uploadProgressNotifier.value = null;
    notifyListeners();
  }

  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}
