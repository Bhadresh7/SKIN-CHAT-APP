import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:skin_chat_app/models/chat_message.dart';
import 'package:skin_chat_app/models/meta_model.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';
import 'package:skin_chat_app/services/chat_service.dart';
import 'package:skin_chat_app/services/hive_service.dart';
import 'package:skin_chat_app/utils/custom_mapper.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  ValueNotifier<List<types.Message>> messageNotifier = ValueNotifier([]);

  ChatProvider() {
    print("I'm Initilized");
    _chatService.initMessageListener();
  }

  ValueNotifier<double?> uploadProgressNotifier = ValueNotifier(null);

  ///stream of messages from realtime database
  Stream<List<types.Message>> get messagesStream => _chatService.messagesStream;

  ///Method to delete messages in the chat and db
  Future<void> deleteMessage(String messageKey) async {
    await _chatService.deleteMessage(messageKey: messageKey);
    await _chatService.deleteMessagesFromLocalStorage(messageId: messageKey);
    notifyListeners();
  }

  // send messages to db and local storage
  Future<void> sendMessage(ChatMessage message) async {
    try {
      print("worked");
      await _chatService.sendMessageToRTDB(message: message);
      await _chatService.addMessagesToLocalStorage(message: message);
      notifyListeners();
    } catch (e) {
      print(e);
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
        provider.userName ?? "",
        (progress) {
          uploadProgressNotifier.value = progress;
        },
      );

      final metaData = MetaModel(img: imageUrl);

      types.ImageMessage(
        author: types.User(id: provider.uid),
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: "${provider.userName ?? "user-"}.jpg",
        size: imageFile.lengthSync(),
        uri: metaData.img.toString(),
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
        provider.userName ?? "",
        (progress) {
          uploadProgressNotifier.value = progress;
        },
      );

      final customMessage = MetaModel(img: imageUrl, text: caption);

      // Create a new CustomMessage with image URL and caption
      types.CustomMessage(
        author: types.User(id: provider.uid),
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        metadata: customMessage.toJson(),
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

  /// get messages from local storage

  List<types.CustomMessage> getAllMessagesFromLocalStorage() {
    final data = HiveService.getAllMessages();
    final message = CustomMapper.getCustomMessage(data);
    return message;
  }

  /// Method to cancel upload
  void cancelUpload() {
    _chatService.cancelUpload();
    uploadProgressNotifier.value = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _chatService.dispose();
    messageNotifier.dispose();
    super.dispose();
  }
}
