import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/models/meta_model.dart';
import 'package:skin_chat_app/providers/exports.dart';
import 'package:skin_chat_app/providers/message/share_content_provider.dart';
import 'package:skin_chat_app/services/hive_service.dart';
import 'package:skin_chat_app/services/notification_service.dart';
import 'package:skin_chat_app/services/user_service.dart';
import 'package:skin_chat_app/utils/custom_mapper.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';
import 'package:skin_chat_app/widgets/common/block_dialog_box.dart';
import 'package:skin_chat_app/widgets/common/chat_placeholder.dart';
import 'package:skin_chat_app/widgets/common/custom_message_widget.dart';
import 'package:skin_chat_app/widgets/common/showDeleteDialog.dart';
import 'package:skin_chat_app/widgets/common/skin_text_field.dart';
import 'package:uuid/uuid.dart';

import '../../models/chat_message_model.dart';
import 'image_preview_screen.dart';

class HomeScreenVarient2 extends StatefulWidget {
  const HomeScreenVarient2({super.key});

  @override
  State<HomeScreenVarient2> createState() => _HomeScreenVarient2State();
}

class _HomeScreenVarient2State extends State<HomeScreenVarient2> {
  late NotificationService service;
  late TextEditingController messageController;
  late AutoScrollController _scrollController;
  late bool isBlockedStatus;

  int? maxLines;
  bool _hasHandledSharedFile = false;
  bool _hasFetchedLinkMetadata = false;
  bool _hasShownBlockDialog = false;

  // Fixed initState method
  @override
  void initState() {
    super.initState();

    // ✅ Initialize ScrollController first
    _scrollController = AutoScrollController();

    final FlutterLocalNotificationsPlugin plugin =
        FlutterLocalNotificationsPlugin();
    plugin.cancelAll();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.startRealtimeListener();
    chatProvider.initMessageStream();
    print("Hey there init Called");
    messageController = TextEditingController();
    service = NotificationService();

    isBlockedStatus = HiveService.getCurrentUser()?.isBlocked ?? false;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          final initialMessages = chatProvider.getAllMessagesFromLocalStorage();
          chatProvider.messageNotifier.value = initialMessages;
        }
      },
    );

    _scrollController.addListener(_onScroll);
  }

  //  scroll listener method
  void _onScroll() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Check if we have messages and can load more
    if (!chatProvider.hasMoreMessages || chatProvider.isLoadingOlderMessages) {
      return;
    }

    // Get current messages from the notifier
    final messages = chatProvider.messageNotifier.value;
    if (messages.isEmpty) return;

    // Use AutoScrollController to check if the oldest message is visible
    // The key here is to check if we're near the end of the list (oldest messages)
    final scrollPosition = _scrollController.position;

    // Check if we're at the maximum scroll extent (most reliable)
    if (scrollPosition.pixels >= scrollPosition.maxScrollExtent - 50) {
      print(
          "🔝 User reached the first/oldest message, fetching older messages...");
      chatProvider.fetchOlderMessages();
      return;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final shareIntentProvider =
        Provider.of<ShareIntentProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<MyAuthProvider>(context, listen: false);
    final shareContentProvider =
        Provider.of<SharedContentProvider>(context, listen: false);
    final sharedFiles = shareIntentProvider.sharedFiles;

    print("==============================");
    print("SHARED FILES ==>$sharedFiles");
    print("_hasHandledSharedFile: $_hasHandledSharedFile");
    print("_hasFetchedLinkMetadata: $_hasFetchedLinkMetadata");
    print("==============================");

    // Only process shared content if we haven't handled it yet and there's actual content
    if (authProvider.currentUser?.canPost ?? false) {
      if (!_hasHandledSharedFile &&
          sharedFiles != null &&
          sharedFiles.isNotEmpty) {
        final sendingContent = sharedFiles[0];
        final isUrl = sendingContent.type == SharedMediaType.URL;

        print("url$isUrl--$sendingContent");

        if (!isUrl) {
          // Mark as handled to prevent multiple dialogs/actions
          _hasHandledSharedFile = true;

          // Handle image sharing with ImagePreviewScreen
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              final imgFile = File(sendingContent.value ?? "");

              // Get initial text from multiple possible sources
              String initialText = "";

              // Fallback to imageMetadata if no direct text
              if (shareContentProvider.imageMetadata != null &&
                  shareContentProvider.imageMetadata!.isNotEmpty) {
                initialText = shareContentProvider.imageMetadata ?? "";
              }

              print("Initial text for image: '$initialText'");

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImagePreviewScreen(
                    image: imgFile,
                    initialText: initialText.toString(),
                    onSend: (caption) async {
                      // Handle the image with or without caption
                      if (caption.isNotEmpty) {
                        // await chatProvider.startRealtimeListener();
                        chatProvider.handleImageWithTextMessage(
                          authProvider,
                          imgFile,
                          caption,
                        );
                      } else {
                        // await chatProvider.startRealtimeListener();
                        chatProvider.handleImageMessage(
                          authProvider,
                          imgFile,
                        );
                      }
                      // Clean up
                      shareIntentProvider.clear();

                      // Reset flag after successful send with delay
                      Future.delayed(Duration(milliseconds: 300), () {
                        if (mounted) {
                          _hasHandledSharedFile = false;
                          print("🔄 Image shared file flag reset after send");
                        }
                      });
                    },
                  ),
                ),
              ).then((_) {
                // Handle case where user cancels without sending
                shareIntentProvider.clear();

                // Reset flag after navigation closes with delay
                Future.delayed(Duration(milliseconds: 300), () {
                  if (mounted) {
                    _hasHandledSharedFile = false;
                    print("🔄 Image shared file flag reset after cancel");
                  }
                });
              });
            },
          );
        } else {
          // Handle URL sharing - FIXED VERSION
          if (!_hasFetchedLinkMetadata) {
            final url = sendingContent.value!;

            // Only mark URL metadata as handled, not the shared file
            _hasFetchedLinkMetadata = true;

            print("controller int - $messageController");
            print("url555555555555555555555555${url}");

            // Use postFrameCallback to ensure controller is ready
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && messageController.text != url) {
                messageController.text = url;
                print("✅ URL set in controller: ${messageController.text}");
              }
            });

            // Clear the share intent after processing URL
            shareIntentProvider.clear();
            print("✅ Share intent cleared after URL processing");

            // Reset the URL metadata flag immediately since we only needed it
            // to prevent duplicate URL processing, not to prevent new URL shares
            Future.delayed(Duration(milliseconds: 100), () {
              if (mounted) {
                _hasFetchedLinkMetadata = false;
                print("🔄 URL metadata flag reset");
              }
            });
          }
        }
      }
    } else {
      // shareContentProvider.clear();
      // shareIntentProvider.clear();
      return;
    }
  }

  // Add this method to reset URL flags after message is sent
  void _resetUrlFlags() {
    _hasHandledSharedFile = false;
    _hasFetchedLinkMetadata = false;
    print("🔄 URL flags reset after message sent");
  }

  // Fixed dispose method
  @override
  void dispose() {
    _scrollController.dispose(); // ✅ Dispose ScrollController
    messageController.dispose();
    super.dispose();
  }

  String? extractFirstUrl(String text) {
    final urlRegex = RegExp(
      r'(?:(?:https?|ftp)://)?(?:[\w-]+\.)+[a-z]{2,}(?:/\S*)?',
      caseSensitive: false,
    );

    final match = urlRegex.firstMatch(text);
    return match?.group(0);
  }

  Future<void> _handleSendMessage(
      String messageText,
      MyAuthProvider authProvider,
      ChatProvider chatProvider,
      NotificationService service,
      ShareIntentProvider shareIntentProvider,
      SharedContentProvider shareContentProvider,
      ImagePickerProvider imagePickerProvider) async {
    if (messageText.isEmpty) return;

    final url = extractFirstUrl(messageText);

    final metaModel = MetaModel(
      img: null,
      url: url,
      text: messageText,
    );

    final newMessage = ChatMessageModel(
      id: const Uuid().v4(),
      author: types.User(
        id: authProvider.uid,
        firstName: HiveService.getCurrentUser()?.username,
      ),
      metaModel: metaModel,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    // Add message to ValueNotifier
    final chatMessage = CustomMapper.mapCustomMessageModalToChatMessage(
      userId: authProvider.uid,
      newMessage,
    );

    // Clear controller first
    if (mounted) {
      messageController.clear();
      print("✅ Controller cleared in handleSendMessage");
    }

    chatProvider.addMessageToNotifier(chatMessage);

    try {
      // await chatProvider.startRealtimeListener();
      await chatProvider.sendMessage(newMessage);

      // Clear all providers
      shareIntentProvider.clear();
      shareContentProvider.clear();
      imagePickerProvider.clear();

      // Reset URL flags after successful send
      _resetUrlFlags();

      print("✅ Message sent and all providers cleared");
    } catch (e) {
      print("❌ Error sending message: $e");
      // Don't reset flags on error so user can retry
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Providers
    final chatProvider = Provider.of<ChatProvider>(context);
    final authProvider = Provider.of<MyAuthProvider>(context);
    final imagePickerProvider = Provider.of<ImagePickerProvider>(context);
    final shareIntentProvider = Provider.of<ShareIntentProvider>(context);
    final shareContentProvider = Provider.of<SharedContentProvider>(context);
    final userService = UserService();

    return PopScope(
      canPop: false,
      child: BackgroundScaffold(
        margin: const EdgeInsets.all(0),
        showDrawer: true,
        appBar: AppBar(
          toolbarHeight: 0.09.sh,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 0.03.sh,
                child: Image.asset(AppAssets.logo),
              ),
              SizedBox(width: 0.02.sw),
              StreamBuilder<Map<String, dynamic>>(
                stream: authProvider.adminUserCountStream,
                builder: (context, snapshot) {
                  final employeeCount = snapshot.data?["admin"] ?? 0;
                  final candidateCount = snapshot.data?["user"] ?? 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("S.K.I.N. App"),
                      Row(
                        children: [
                          Text(
                            "Employer: ${employeeCount.toString()}",
                            style: TextStyle(fontSize: AppStyles.bodyText),
                          ),
                          SizedBox(width: 0.02.sw),
                          Text(
                            "Candidate: ${candidateCount.toString()}",
                            style: TextStyle(fontSize: AppStyles.bodyText),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              )
            ],
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // ✅ Loading indicator for older messages
                Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    if (chatProvider.isLoadingOlderMessages) {
                      return Container(
                        color: AppStyles.smoke,
                        padding: EdgeInsets.all(AppStyles.padding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 24.sp, // Increased from 16.sp
                              height: 24.sp, // Increased from 16.sp
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: AppStyles.padding),
                            Text(
                              "Loading older messages...",
                              style: TextStyle(fontSize: AppStyles.subTitle),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // ✅ Chat widget with custom scroll controller
                Expanded(
                  child: ValueListenableBuilder<List<types.CustomMessage>>(
                    valueListenable: chatProvider.messageNotifier,
                    builder: (context, messages, child) {
                      print(
                          "🔄 UI rebuilding with ${messages.length} messages");

                      return Chat(
                        scrollController: _scrollController,
                        emptyState: messages.isEmpty ? ChatPlaceholder() : null,
                        theme: DefaultChatTheme(
                          dateDividerMargin: EdgeInsets.all(0.03.sh),
                          dateDividerTextStyle: const TextStyle(fontSize: 15),
                          inputBackgroundColor: AppStyles.primary,
                          inputTextCursorColor: AppStyles.smoke,
                          inputBorderRadius:
                              const BorderRadius.all(Radius.circular(0)),
                        ),
                        timeFormat: DateFormat("d/MM/yyyy - hh:mm a "),
                        inputOptions: InputOptions(
                          textEditingController: messageController,
                          sendButtonVisibilityMode:
                              SendButtonVisibilityMode.always,
                        ),
                        onMessageLongPress: (context, message) async {
                          ShowDeleteDialog.showDeleteDialog(
                            context,
                            message,
                            chatProvider,
                            authProvider,
                          );
                        },
                        customMessageBuilder: (message,
                            {required messageWidth}) {
                          return CustomMessageWidget(
                            key: ValueKey(message.id),
                            messageData: message.metadata ?? {},
                            messageWidth: 1.sw,
                          );
                        },
                        // ✅ Cast to types.Message for Chat widget compatibility
                        messages: messages.cast<types.Message>(),
                        onSendPressed: (message) async {
                          await _handleSendMessage(
                            message.text,
                            authProvider,
                            chatProvider,
                            service,
                            shareIntentProvider,
                            shareContentProvider,
                            imagePickerProvider,
                          );
                        },
                        user: types.User(
                          firstName: HiveService.getCurrentUser()?.username,
                          id: authProvider.uid,
                        ),
                        showUserNames: true,
                        showUserAvatars: true,
                        customBottomWidget: StreamBuilder<Map<String, dynamic>>(
                          stream: userService.fetchRoleAndSaveLocally(),
                          builder: (context, snapshot) {
                            final canPost = snapshot.data?['canPost'] ??
                                authProvider.currentUser?.canPost ??
                                HiveService.getCurrentUser()?.canPost ??
                                false;

                            final isBlocked =
                                snapshot.data?['isBlocked'] ?? isBlockedStatus;

                            if (isBlocked && !_hasShownBlockDialog) {
                              _hasShownBlockDialog = true;

                              WidgetsBinding.instance.addPostFrameCallback(
                                (_) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => BlockDialogBox(
                                        authProvider: authProvider),
                                  ).then(
                                    (_) {
                                      _hasShownBlockDialog = false;
                                    },
                                  );
                                },
                              );

                              return const SizedBox.shrink();
                            }

                            if (!canPost || isBlocked) {
                              return const SizedBox.shrink();
                            }

                            return SkinTextField(
                                messageController: messageController);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            /// Upload Progress Overlay (remains the same)
            ValueListenableBuilder<double?>(
              valueListenable: chatProvider.uploadProgressNotifier,
              builder: (context, progress, child) {
                if (progress == null) {
                  return const SizedBox.shrink();
                }

                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.blue),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "${(progress * 100).toStringAsFixed(0)}% uploaded",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                chatProvider.cancelUpload();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
