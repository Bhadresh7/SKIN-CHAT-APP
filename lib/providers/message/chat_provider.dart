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

  ValueNotifier<double?> uploadProgressNotifier = ValueNotifier(null);

  ///stream of messages from realtime database
  Stream<List<types.Message>> get messagesStream =>
      _chatService.getMessagesStream();

  ///Method to delete messages in the chat
  Future<void> deleteMessage(String messageKey) async {
    await _chatService.deleteMessage(messageKey: messageKey);

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

        // _messages.insert(0, newMessage);
      }
    } catch (e) {
      print("❌ Error in sendMessage: $e");
    } finally {
      notifyListeners();
    }
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

      types.ImageMessage(
        author: types.User(id: provider.uid),
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: "${provider.userName ?? provider.formUserName}.jpg",
        size: imageFile.lengthSync(),
        uri: imageUrl,
      );

      uploadProgressNotifier.value = null;
      notifyListeners();
    } catch (e) {
      print("❌ Error in handleImageMessage: $e");
      uploadProgressNotifier.value = null;
    }
  }

  Future<void> handleImageWithTextMessage(
    MyAuthProvider provider,
    File img,
    String? caption,
  ) async {
    try {
      uploadProgressNotifier.value = 0.0;

      // Use the new uploadImageAndSendWithCaption method
      final imageUrl = await _chatService.uploadImageAndSendWithCaption(
        img,
        caption ?? '',
        provider.uid,
        provider.userName ?? provider.formUserName,
        (progress) {
          uploadProgressNotifier.value = progress;
        },
      );

      // Reset the progress and notify listeners
      uploadProgressNotifier.value = null;
      notifyListeners();
    } catch (e) {
      print(e);
      // Consider adding error handling here
      uploadProgressNotifier.value = null;
      notifyListeners();
    }
  }

  /// Method to cancel upload
  void cancelUpload() {
    _chatService.cancelUpload();
    uploadProgressNotifier.value = null;
    notifyListeners();
  }
}
