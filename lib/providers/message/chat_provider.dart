import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:skin_chat_app/models/custom_message_modal.dart';
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

  // Future<void> sendMessage(dynamic message, MyAuthProvider provider) async {
  //   try {
  //     if (message is types.PartialText) {
  //       final newMessage = types.TextMessage(
  //         author: types.User(
  //             id: provider.uid,
  //             firstName: provider.userName ?? provider.formUserName),
  //         id: DateTime.now().millisecondsSinceEpoch.toString(),
  //         text: message.text,
  //       );
  //
  //       await _chatService.sendMessage(
  //         message: newMessage.text,
  //         userId: provider.uid,
  //         userName: provider.userName ?? provider.formUserName,
  //       );
  //     }
  //   } catch (e) {
  //     print("❌ Error in sendMessage: $e");
  //   } finally {
  //     notifyListeners();
  //   }
  // }

  Future<void> sendMessage(
      CustomMessageModal message, MyAuthProvider provider) async {
    try {
      print("-------------------${message.toJson()}");
      final customMessage = types.CustomMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          metadata: message.toJson(),
          author: types.User(
              id: provider.currentUser!.uid,
              firstName: provider.userName ?? provider.formUserName));
      await _chatService.sendMessage(
        message: message,
        userId: provider.uid,
        userName: provider.userName ?? provider.formUserName,
      );
    } catch (e) {
      print(e);
    }
  }

  //
  // final customMessage = types.CustomMessage(
  //   author: _user,
  //   createdAt: DateTime.now().millisecondsSinceEpoch,
  //   id: 'unique-id =========>   $count',
  //
  //   metadata: {
  //     'text': 'Hello!',
  //     'image':
  //     'https://img.freepik.com/free-photo/cosmos-flowers_1373-83.jpg?semt=ais_hybrid&w=740',
  //     'url': 'https://www.apple.com/in/',
  //   },
  // );
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

      final customMessage = CustomMessageModal(img: imageUrl);

      final newMessage = types.ImageMessage(
        author: types.User(id: provider.uid),
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: "${provider.userName ?? provider.formUserName}.jpg",
        size: imageFile.lengthSync(),
        uri: customMessage.img.toString(),
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

      final customMessage = CustomMessageModal(img: imageUrl, text: caption);

      // Create a new CustomMessage with image URL and caption
      types.CustomMessage(
          author: types.User(id: provider.uid),
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          metadata: customMessage.toJson()
          // metadata: {
          //   'type': 'image_with_caption',
          //   'imageUrl': imageUrl,
          //   'caption': caption ?? '',
          //   'fileName': "${provider.userName ?? provider.formUserName}.jpg",
          // },
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
