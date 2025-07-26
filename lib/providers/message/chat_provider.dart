import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:skin_chat_app/models/chat_message_model.dart';
import 'package:skin_chat_app/models/meta_model.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';
import 'package:skin_chat_app/providers/internet/internet_provider.dart';
import 'package:skin_chat_app/services/chat_service.dart';
import 'package:skin_chat_app/services/hive_service.dart';
import 'package:skin_chat_app/services/notification_service.dart';
import 'package:skin_chat_app/utils/custom_mapper.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("chats");

  final internetProvider = InternetProvider();
  final NotificationService _notificationService = NotificationService();
  ValueNotifier<double?> uploadProgressNotifier = ValueNotifier(null);

  // Message notifier - always represents local storage state
  ValueNotifier<List<types.CustomMessage>> messageNotifier = ValueNotifier([]);
  StreamSubscription<List<types.CustomMessage>>? _subscription;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _messageDeleteSubscription;
  final localData = HiveService.getAllMessages();

  // 📄 Pagination state
  bool _isLoadingOlderMessages = false;
  bool _hasMoreMessages = true;
  final int _messagesPerPage = 30;

  // 🆕 Session tracking for real-time listening
  int? _realtimeSessionStartTs;

  // Getters for pagination state
  bool get isLoadingOlderMessages => _isLoadingOlderMessages;

  bool get hasMoreMessages => _hasMoreMessages;

  // Load messages from local storage
  Future<void> _loadLocalMessages() async {
    final List<ChatMessageModel> localMessages = HiveService.getAllMessages();
    final converted = CustomMapper.getCustomMessage(localMessages);
    messageNotifier.value = converted;
    print("📱 Loaded ${converted.length} messages from local storage");
  }

  // Start real-time listener for new messages
  bool _isListening = false;

  Future<void> startRealtimeListener() async {
    if (_isListening) return; // Prevent multiple listeners
    _isListening = true;

    await _messageSubscription?.cancel();

    //  Set session start timestamp to NOW when starting listener
    _realtimeSessionStartTs = await HiveService.getLastSavedTimestamp();

    /// This handles when the user initially login
    /// The user will not be having the last timestamp
    if (_realtimeSessionStartTs == 0) {
      return;
    }
    print(
        "🕐 Real-time session started at timestamp: $_realtimeSessionStartTs");

    _messageSubscription = _databaseRef
        .orderByChild("ts")
        .startAfter(_realtimeSessionStartTs!)
        .onChildAdded
        .listen(
      (event) => _handleSingleNewMessage(event.snapshot),
      onError: (error) {
        print("❌ Real-time listener error: $error");
        Future.delayed(Duration(seconds: 5), () {
          _isListening = false;
          startRealtimeListener();
        });
      },
      cancelOnError: false,
    );

    _databaseRef.onChildRemoved.listen((event) {
      final deletedId = event.snapshot.key;
      if (deletedId != null) {
        print("Message deleted $deletedId");
        removeMessageFromNotifier(deletedId);
        notifyListeners();
      }
    }, onError: (error) {
      print(error.toString());
    });
  }

  // Handle single message from real-time stream
  void _handleSingleNewMessage(DataSnapshot snapshot) {
    final data = snapshot.value;
    if (data is! Map || data.isEmpty) {
      print("📭 No message data");
      return;
    }

    // ✅ Process single message (not multiple)
    final messageId = snapshot.key;
    if (messageId == null) return;

    final messageTimestamp =
        data["ts"] ?? DateTime.now().millisecondsSinceEpoch;

    // 🔧 KEY FIX: Only process messages that are truly newer than session start
    if (_realtimeSessionStartTs != null &&
        messageTimestamp <= _realtimeSessionStartTs!) {
      print("⏰ Skipping message from before session start: $messageId");
      return;
    }

    final author = types.User(
      id: data["id"]?.toString() ?? '',
      firstName: data["name"]?.toString() ?? "k",
    );

    final metadata = data["metadata"];

    if (metadata is! Map) return;

    final newMessage = types.CustomMessage(
      id: messageId,
      author: author,
      createdAt: messageTimestamp,
      metadata: {
        "text": metadata["text"],
        "url": metadata["url"],
        "img": metadata["img"],
      },
    );

    print(
        "🔥 New real-time message received: ${metadata["text"] ?? 'No text'}");

    // ✅ Process single message and update UI
    _processSingleNewMessage(newMessage);
  }

  // Process single new message for real-time updates
  void _processSingleNewMessage(types.CustomMessage newMessage) {
    // Save to local storage
    final chatModel = CustomMapper.mapCustomToChatMessage(newMessage);
    HiveService.saveMessage(message: chatModel);
    print(
        "💾 Real-time message saved: ${chatModel.metaModel.text ?? 'No text'}");

    // Update last timestamp
    HiveService.saveLastTimestamp(newMessage.createdAt ?? 0);

    // Check if message already exists (prevent duplicates)
    final currentMessages =
        List<types.CustomMessage>.from(messageNotifier.value);
    final existingIndex =
        currentMessages.indexWhere((msg) => msg.id == newMessage.id);

    if (existingIndex == -1) {
      // Add new message to the beginning (newest first)
      currentMessages.insert(0, newMessage);

      // ✅ Update the ValueNotifier - this will trigger ValueListenableBuilder in UI
      messageNotifier.value = currentMessages;

      print("✅ Real-time message added to UI: ${newMessage.id}");

      // ✅ Also notify listeners for any other widgets using Provider
      notifyListeners();
    } else {
      print("⚠️ Duplicate message ignored: ${newMessage.id}");
    }
  }

  // Process and add new messages incrementally
  void _processNewMessages(List<types.CustomMessage> newMessages) {
    // Sort new messages by timestamp (newest first)
    newMessages.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));

    // Save new messages to local storage
    for (var message in newMessages) {
      final chatModel = CustomMapper.mapCustomToChatMessage(message);
      HiveService.saveMessage(message: chatModel);
      print("💾 New message saved: ${chatModel.metaModel.text ?? 'No text'}");
    }

    // Update last timestamp
    HiveService.saveLastTimestamp(newMessages.first.createdAt ?? 0);

    // Get current messages
    List<types.CustomMessage> currentMessages =
        List.from(messageNotifier.value);

    // Add new messages to the beginning (newest first)
    currentMessages.insertAll(0, newMessages);

    // Remove duplicates (in case of race conditions)
    final Map<String, types.CustomMessage> uniqueMessages = {};
    for (var message in currentMessages) {
      uniqueMessages[message.id] = message;
    }

    // Convert back to list and sort
    final updatedMessages = uniqueMessages.values.toList();
    updatedMessages
        .sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));

    // Update the notifier - this will only trigger UI updates for new items
    messageNotifier.value = updatedMessages;

    print("✅ ${newMessages.length} new messages added to UI");
  }

  Future<void> _fetchInitialMessagesIfEmpty() async {
    if (messageNotifier.value.isNotEmpty) {
      print("📦 Hive not empty. No need to fetch initial messages.");
      return;
    }

    print(
        "📭 Hive is empty. Fetching latest $_messagesPerPage messages from Firebase...");

    final snapshot = await _databaseRef
        .orderByChild("ts")
        .limitToLast(_messagesPerPage)
        .once();

    final data = snapshot.snapshot.value;
    if (data is! Map || data.isEmpty) {
      print("❌ No messages found in Firebase.");
      _hasMoreMessages = false;
      notifyListeners();
      return;
    }

    final List<types.CustomMessage> messages = [];

    data.forEach((key, value) {
      if (value is! Map) return;

      final author = types.User(
        id: value["id"]?.toString() ?? '',
        firstName: value["name"]?.toString() ?? "G",
      );

      final timestamp = value["ts"] ?? DateTime.now().millisecondsSinceEpoch;
      final metadata = value["metadata"];

      if (metadata is! Map) return;

      final message = types.CustomMessage(
        id: key,
        author: author,
        createdAt: timestamp,
        metadata: {
          "text": metadata["text"],
          "url": metadata["url"],
          "img": metadata["img"],
        },
      );

      messages.add(message);
    });

    if (messages.isNotEmpty) {
      // 👇 Sort in descending order (newest first)
      messages.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));

      print("📥 ${messages.length} messages fetched from Firebase");

      // Check if we got fewer messages than requested (indicates no more messages)
      if (messages.length < _messagesPerPage) {
        _hasMoreMessages = false;
      }

      _processNewMessages(messages);
      await _loadLocalMessages(); // ✅ reload from Hive to update UI
    } else {
      _hasMoreMessages = false;
    }

    notifyListeners();
  }

  // 🆕 NEW METHOD: Fetch older messages for pagination
  Future<void> fetchOlderMessages() async {
    if (_isLoadingOlderMessages || !_hasMoreMessages) {
      print("🔄 Already loading or no more messages available");
      return;
    }

    _isLoadingOlderMessages = true;
    notifyListeners(); // Notify UI to show loading indicator

    try {
      final currentMessages = messageNotifier.value;

      if (currentMessages.isEmpty) {
        print("⚠️ No current messages to paginate from");
        _isLoadingOlderMessages = false;
        notifyListeners();
        return;
      }

      // Get the oldest message timestamp as reference point
      final oldestMessage = currentMessages.last;
      final oldestTimestamp = oldestMessage.createdAt ?? 0;

      print("📜 Fetching older messages before timestamp: $oldestTimestamp");

      // Query messages older than the oldest current message
      final snapshot = await _databaseRef
          .orderByChild("ts")
          .endAt(oldestTimestamp - 1)
          .limitToLast(_messagesPerPage)
          .once();

      final data = snapshot.snapshot.value;

      if (data is! Map || data.isEmpty) {
        print("📭 No older messages found");
        _hasMoreMessages = false;
        _isLoadingOlderMessages = false;
        notifyListeners();
        return;
      }

      final List<types.CustomMessage> olderMessages = [];

      data.forEach((key, value) {
        if (value is! Map) return;

        final author = types.User(
          id: value["id"]?.toString() ?? '',
          firstName: value["name"]?.toString() ?? "G",
        );

        final timestamp = value["ts"] ?? DateTime.now().millisecondsSinceEpoch;
        final metadata = value["metadata"];

        if (metadata is! Map) return;

        final message = types.CustomMessage(
          id: key,
          author: author,
          createdAt: timestamp,
          metadata: {
            "text": metadata["text"],
            "url": metadata["url"],
            "img": metadata["img"],
          },
        );

        olderMessages.add(message);
      });

      if (olderMessages.isNotEmpty) {
        // Sort older messages by timestamp (newest first)
        olderMessages
            .sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));

        print(
            "📥 ${olderMessages.length} older messages fetched from Firebase");

        // Check if we got fewer messages than requested (indicates no more messages)
        if (olderMessages.length < _messagesPerPage) {
          _hasMoreMessages = false;
        }

        // Save older messages to local storage
        for (var message in olderMessages) {
          final chatModel = CustomMapper.mapCustomToChatMessage(message);
          HiveService.saveMessage(message: chatModel);
          print(
              "💾 Older message saved: ${chatModel.metaModel.text ?? 'No text'}");
        }

        // Add older messages to the end of current messages list
        final updatedMessages = List<types.CustomMessage>.from(currentMessages);
        updatedMessages.addAll(olderMessages);

        // Remove duplicates (just in case)
        final Map<String, types.CustomMessage> uniqueMessages = {};
        for (var message in updatedMessages) {
          uniqueMessages[message.id] = message;
        }

        // Convert back to list and sort (newest first)
        final finalMessages = uniqueMessages.values.toList();
        finalMessages
            .sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));

        // Update the message notifier
        messageNotifier.value = finalMessages;

        print(
            "✅ ${olderMessages.length} older messages added to UI. Total: ${finalMessages.length}");
      } else {
        _hasMoreMessages = false;
      }
    } catch (e) {
      print("❌ Error fetching older messages: $e");
    } finally {
      _isLoadingOlderMessages = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _messageSubscription?.cancel();
    _subscription?.cancel();
    _realtimeSessionStartTs = null; // Clean up session timestamp
  }

  void addMessageToNotifier(types.CustomMessage message) {
    final updatedMessages = [message, ...messageNotifier.value];
    messageNotifier.value = updatedMessages;
    notifyListeners();
  }

  void removeMessageFromNotifier(String messageId) {
    final updatedMessages = messageNotifier.value
        .where((message) => message.id != messageId)
        .toList();

    messageNotifier.value = updatedMessages;
    notifyListeners();
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
        author: types.User(
            id: provider.uid,
            firstName: HiveService.getCurrentUser()?.username),
        id: "$timestamp",
        name: "${provider.userName ?? "user-"}.jpg",
        size: imageFile.lengthSync(),
        uri: imageUrl,
      );

      uploadProgressNotifier.value = null;
      _notificationService.sendNotificationToUsers(
          title: HiveService.getCurrentUser()?.username ?? "",
          content: "Sent an image",
          userId: HiveService.getCurrentUser()?.uid ?? "");
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
        author: types.User(
            id: provider.uid,
            firstName: HiveService.getCurrentUser()?.username),
        id: "$timestamp",
        createdAt: timestamp,
        metadata: MetaModel(img: imageUrl, text: caption).toJson(),
      );

      uploadProgressNotifier.value = null;
      _notificationService.sendNotificationToUsers(
          title: HiveService.getCurrentUser()?.username ?? "",
          content: caption ?? "",
          userId: HiveService.getCurrentUser()?.uid ?? "");
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

  // Initialize and load messages from local storage first
  void initMessageStream() async {
    print("🚀 initMessageStream triggered");

    // Debug: Check what's in Hive before loading
    final hiveMessages = HiveService.getAllMessages();
    print(
        "🔍 DEBUG: Hive contains ${hiveMessages.length} messages before loading");

    // Step 1: Always load local messages first
    await _loadLocalMessages();

    // Debug: Check messageNotifier after loading
    print(
        "🔍 DEBUG: MessageNotifier has ${messageNotifier.value.length} messages after loading");

    // Step 2: Only fetch from Firebase if local storage is empty
    if (messageNotifier.value.isEmpty) {
      print(
          "📭 Local storage is empty. Fetching initial messages from Firebase...");
      await _fetchInitialMessagesIfEmpty();
    } else {
      print(
          "📦 Found ${messageNotifier.value.length} messages in local storage. Skipping Firebase fetch.");
    }

    // 🔧 KEY FIX: Start real-time listener AFTER loading existing messages
    print("🎧 Starting real-time listener for new messages...");
    await startRealtimeListener();
  }

  // 🆕 Method to stop real-time listening (useful for cleanup)
  void stopRealtimeListener() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _isListening = false;
    _realtimeSessionStartTs = null;
    print("🛑 Real-time listener stopped");
  }
}
