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
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/helpers/my_navigation.dart';
import 'package:skin_chat_app/helpers/toast_helper.dart';
import 'package:skin_chat_app/models/meta_model.dart';
import 'package:skin_chat_app/providers/exports.dart';
import 'package:skin_chat_app/providers/message/share_content_provider.dart';
import 'package:skin_chat_app/screens/auth/login_screen.dart';
import 'package:skin_chat_app/services/hive_service.dart';
import 'package:skin_chat_app/services/notification_service.dart';
import 'package:skin_chat_app/services/user_service.dart';
import 'package:skin_chat_app/utils/custom_mapper.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';
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

  // late Stream<Map<String, dynamic>> canPostAccessStream;

  int? maxLines;
  bool _hasHandledSharedFile = false;
  bool _hasFetchedLinkMetadata = false;
  bool _hasControllerInited = false;
  bool _hasHandledBlock = false;

// Fixed _updateMaxLines method
//   void _updateMaxLines() {
//     if (mounted) {
//       setState(() {
//         maxLines = messageController.text.trim().isEmpty ? null : 2;
//       });
//     }
//   }

// Fixed initState method
  @override
  void initState() {
    final FlutterLocalNotificationsPlugin plugin =
        FlutterLocalNotificationsPlugin();
    plugin.cancelAll();
    super.initState();
    print("Hey there init Called");
    // canPostAccessStream = context.read<MyAuthProvider>().canPostAccessStream;
    messageController = TextEditingController();
    // messageController.addListener(_updateMaxLines);
    // service = NotificationService();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        final initialMessages = chatProvider.getAllMessagesFromLocalStorage();
        chatProvider.messageNotifier.value = initialMessages;
      }
    });
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

    if ((authProvider.currentUser?.canPost ?? false) && !_hasControllerInited) {
      messageController = TextEditingController();
      _hasControllerInited = true;
      print("✅ Controller initialized");
    }

    messageController.clear();
    if (!(authProvider.currentUser?.canPost ?? false) && _hasControllerInited) {
      messageController.dispose();
      _hasControllerInited = false;
      print("❌ Controller disposed");
    }
    print("==============================");
    print("SHARED FILES ==>$sharedFiles");
    print("==============================");

    // Only process shared content if we haven't handled it yet and there's actual content
    if (authProvider.currentUser?.canPost ?? false) {
      if (!_hasHandledSharedFile &&
          sharedFiles != null &&
          sharedFiles.isNotEmpty) {
        final sendingContent = sharedFiles[0];
        final isUrl = sendingContent.type == SharedMediaType.URL;

        // Mark as handled to prevent multiple dialogs/actions
        _hasHandledSharedFile = true;

        print("url$isUrl--$sendingContent");

        if (!isUrl) {
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
                        chatProvider.handleImageWithTextMessage(
                          authProvider,
                          imgFile,
                          caption,
                        );
                      } else {
                        chatProvider.handleImageMessage(
                          authProvider,
                          imgFile,
                        );
                      }

                      // Clean up
                      shareIntentProvider.clear();
                      _hasHandledSharedFile = false;
                    },
                  ),
                ),
              ).then((_) {
                // Handle case where user cancels without sending
                if (_hasHandledSharedFile) {
                  shareIntentProvider.clear();
                  _hasHandledSharedFile = false;
                }
              });
            },
          );
        } else {
          // Handle URL sharing (keep existing logic)
          if (!_hasFetchedLinkMetadata) {
            final url = sendingContent.value!;
            _hasFetchedLinkMetadata = true;
            print("controller int - $messageController");
            print("url555555555555555555555555${url}");
            messageController.text = url;
            _hasHandledSharedFile = false;
            _hasFetchedLinkMetadata = false;
          }
        }
      }
    } else {
      // shareContentProvider.clear();
      // shareIntentProvider.clear();
      return;
    }
  }

// Fixed dispose method
  @override
  void dispose() {
    // messageController.removeListener(_updateMaxLines);
    messageController.dispose();
    super.dispose();
  }

// Fixed _clearController method
  void _clearController() {
    if (mounted && _hasControllerInited) {
      messageController.clear();
    }
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
        firstName: authProvider.currentUser?.username,
      ),
      metaModel: metaModel,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    // Add message to ValueNotifier
    final chatMessage = CustomMapper.mapCustomMessageModalToChatMessage(
      userId: authProvider.uid,
      newMessage,
    );

    _clearController();
    // _updateMaxLines();
    chatProvider.addMessageToNotifier(chatMessage);

    await chatProvider.sendMessage(newMessage);
    await service.sendNotificationToUsers(
      title: authProvider.currentUser?.username ?? "",
      content: newMessage.metaModel.text ??
          newMessage.metaModel.img ??
          newMessage.metaModel.url ??
          "",
      userId: authProvider.currentUser?.uid ?? "",
    );

    shareIntentProvider.clear();
    shareContentProvider.clear();
    imagePickerProvider.clear();
  }

  @override
  Widget build(BuildContext context) {
    /// Providers
    final chatProvider = Provider.of<ChatProvider>(context);
    final internetProvider = Provider.of<InternetProvider>(context);
    final authProvider = Provider.of<MyAuthProvider>(context);
    final imagePickerProvider = Provider.of<ImagePickerProvider>(context);
    final shareIntentProvider = Provider.of<ShareIntentProvider>(context);
    final shareContentProvider = Provider.of<SharedContentProvider>(context);
    final _service = UserService();

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
            // Use ValueListenableBuilder to listen to messageNotifier changes
            ValueListenableBuilder<List<types.Message>>(
              valueListenable: chatProvider.messageNotifier,
              builder: (context, messages, child) {
                return Chat(
                  emptyState: messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Welcome to Skin Chats",
                                style: TextStyle(
                                  fontSize: AppStyles.heading,
                                  color: AppStyles.tertiary,
                                ),
                              ),
                              Text(
                                "Start your journey",
                                style: TextStyle(color: AppStyles.tertiary),
                              ),
                            ],
                          ),
                        )
                      : null,
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
                    sendButtonVisibilityMode: SendButtonVisibilityMode.always,
                  ),
                  onMessageLongPress: (context, message) async {
                    if (internetProvider.connectionStatus ==
                            AppStatus.kDisconnected ||
                        internetProvider.connectionStatus == AppStatus.kSlow) {
                      return ToastHelper.showErrorToast(
                        context: context,
                        message: "Please check your internet connection",
                      );
                    }

                    ShowDeleteDialog.showDeleteDialog(
                      context,
                      message,
                      chatProvider,
                      authProvider,
                    );
                  },
                  customMessageBuilder: (message, {required messageWidth}) {
                    return CustomMessageWidget(
                      key: ValueKey(message.id),
                      messageData: message.metadata ?? {},
                      messageWidth: 1.sw,
                    );
                  },
                  messages: messages,
                  onSendPressed: (message) async {
                    if (internetProvider.connectionStatus ==
                            AppStatus.kDisconnected ||
                        internetProvider.connectionStatus == AppStatus.kSlow) {
                      ToastHelper.showErrorToast(
                        context: context,
                        message: "Please check your internet connection",
                      );
                      return;
                    }

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
                    stream: _service.fetchRoleAndSaveLocally(),
                    builder: (context, snapshot) {
                      print("I'M EMITTED UI !!!!!!!!");
                      print("SNAPSHOT DATA ${snapshot.data}");

                      final canPost = snapshot.data?['canPost'] ??
                          authProvider.currentUser?.canPost ??
                          HiveService.getCurrentUser()?.canPost ??
                          false;

                      final isBlocked = snapshot.data?['isBlocked'] ?? false;

                      if (isBlocked && !_hasHandledBlock) {
                        _hasHandledBlock = true;
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) async {
                            await authProvider.signOut();
                            if (context.mounted) {
                              MyNavigation.replace(
                                  context, const LoginScreen());
                            }
                          },
                        );
                      }

                      if (!canPost) return const SizedBox.shrink();

                      return SkinTextField(
                          messageController: messageController);
                    },
                  ),
                );
              },
            ),

            /// Upload Progress Overlay
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
