import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/models/chat_message_model.dart';
import 'package:skin_chat_app/models/meta_model.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';
import 'package:skin_chat_app/providers/internet/internet_provider.dart';
import 'package:skin_chat_app/services/chat_service.dart';
import 'package:skin_chat_app/services/fetch_metadata.dart';
import 'package:skin_chat_app/services/hive_service.dart';
import 'package:skin_chat_app/utils/custom_mapper.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final internetProvider = InternetProvider();

  ValueNotifier<List<types.CustomMessage>> messageNotifier = ValueNotifier([]);
  ValueNotifier<double?> uploadProgressNotifier = ValueNotifier(null);
  StreamSubscription<List<types.CustomMessage>>? _subscription;

  ChatProvider() {
    initMessageStream();
  }

  void initMessageStream() async {
    if (internetProvider.connectionStatus == AppStatus.kDisconnected) {
      HiveService.getAllMessages();
    } else {
      _chatService.dispose();

      final existingMessageIds = await HiveService.getAllMessageIdsSet();

      _chatService.initMessageListener();

      _subscription = _chatService.messagesStream.listen(
        (messages) => _handleIncomingMessages(messages, existingMessageIds),
      );
    }
  }

  Future<void> _handleIncomingMessages(
    List<types.CustomMessage> messages,
    Set<String> existingMessageIds,
  ) async {
    messageNotifier.value = messages;

    for (final customMsg in messages) {
      if (!existingMessageIds.contains(customMsg.id)) {
        await _handleNewMessage(customMsg, existingMessageIds);
      }
    }
  }

  Future<void> _handleNewMessage(
    types.CustomMessage customMsg,
    Set<String> existingMessageIds,
  ) async {
    final chatMsg = CustomMapper.mapCustomToChatMessage(customMsg);

    final previewData = await FetchMeta().fetchLinkMetadata(
      chatMsg.metaModel.url ?? "",
    );

    chatMsg.metaModel.previewDataModel = previewData;
    existingMessageIds.add(customMsg.id);

    await HiveService.saveMessage(message: chatMsg);
  }

  void addMessageToNotifier(types.CustomMessage message) {
    final updatedMessages = [message, ...messageNotifier.value];
    messageNotifier.value = updatedMessages;
  }

  void removeMessageFromNotifier(String messageId) {
    final updatedMessages = messageNotifier.value
        .where((message) => message.id != messageId)
        .toList();

    messageNotifier.value = updatedMessages;
  }

  Future<void> deleteMessage({
    required String messageId,
    required String userId,
  }) async {
    try {
      Future.wait([
        _chatService.deleteMessage(messageId: messageId),
        _chatService.deleteMessagesFromLocalStorage(messageId: messageId),
        _chatService.deleteImageFromStorage(
            messageId: messageId, userId: userId)
      ]);
    } catch (e) {
      print(e.toString());
    }
    removeMessageFromNotifier(messageId);
    notifyListeners();
  }

  Future<void> sendMessage(ChatMessageModel message) async {
    try {
      await _chatService.sendMessageToRTDB(message: message);
      await _chatService.addMessagesToLocalStorage(message: message);
      notifyListeners();
    } catch (e) {
      print("❌ Error in sendMessage: $e");
    }
  }

  Future<void> handleImageMessage(
    MyAuthProvider provider,
    File imageFile,
  ) async {
    try {
      uploadProgressNotifier.value = 0.0;

      final imageUrl = await _chatService.uploadImageAndSend(
        imageFile,
        provider.uid,
        (progress) => uploadProgressNotifier.value = progress,
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final _ = types.ImageMessage(
        author: types.User(id: provider.uid),
        id: "$timestamp",
        name: "${provider.userName ?? "user-"}.jpg",
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

      final imageUrl = await _chatService.uploadImageAndSendWithCaption(
        img,
        caption ?? '',
        provider.uid,
        (progress) => uploadProgressNotifier.value = progress,
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final _ = types.CustomMessage(
        author: types.User(id: provider.uid),
        id: "$timestamp",
        createdAt: timestamp,
        metadata: MetaModel(img: imageUrl, text: caption).toJson(),
      );

      uploadProgressNotifier.value = null;
      notifyListeners();
    } catch (e) {
      print("❌ Error in handleImageWithTextMessage: $e");
      uploadProgressNotifier.value = null;
    }
  }

  List<types.CustomMessage> getAllMessagesFromLocalStorage() {
    final data = HiveService.getAllMessages();
    return CustomMapper.getCustomMessage(data);
  }

  void cancelUpload() {
    _chatService.cancelUpload();
    uploadProgressNotifier.value = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    messageNotifier.dispose();
    super.dispose();
  }
}
