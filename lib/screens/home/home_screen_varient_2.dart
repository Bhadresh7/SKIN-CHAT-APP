import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/helpers/toast_helper.dart';
import 'package:skin_chat_app/providers/exports.dart';
import 'package:skin_chat_app/services/Appversion_service.dart'
    show AppversionService;
import 'package:skin_chat_app/services/notification_service.dart';
import 'package:skin_chat_app/widgets/buttons/custom_button.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';
import 'package:skin_chat_app/widgets/common/chat_placeholder.dart';

import '../../widgets/common/showDeleteDialog.dart' show Showdeletedialog;

class HomeScreenVarient2 extends StatefulWidget {
  const HomeScreenVarient2({super.key});

  @override
  State<HomeScreenVarient2> createState() => _HomeScreenVarient2State();
}

class _HomeScreenVarient2State extends State<HomeScreenVarient2> {
  late NotificationService service;
  late TextEditingController messageController;

  @override
  void initState() {
    super.initState();
    AppversionService.getAppVersion();
    messageController = TextEditingController();
    service = NotificationService();
    final authProvider = Provider.of<MyAuthProvider>(context, listen: false);
    authProvider.listenToRoleChanges(authProvider.email);
    authProvider.getUserDetails(email: authProvider.email);
  }

  bool _hasHandledSharedFile = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final shareIntentProvider = Provider.of<ShareIntentProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<MyAuthProvider>(context, listen: false);
    final sharedFiles = shareIntentProvider.sharedFiles;

    // ✅ Check for null and non-empty list
    if (!_hasHandledSharedFile &&
        sharedFiles != null &&
        sharedFiles.isNotEmpty) {
      final sendingContent = sharedFiles[0];
      final isUrl = sendingContent.type == SharedMediaType.URL;

      _hasHandledSharedFile = true;

      if (!isUrl) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Send this image?'),
              content: Image.file(File(sendingContent.value!)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _hasHandledSharedFile = false;
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    chatProvider.handleImageMessage(
                      authProvider,
                      File(sendingContent.value!),
                    );
                    shareIntentProvider.clear();
                    _hasHandledSharedFile = false;
                  },
                  child: Text('Send'),
                ),
              ],
            ),
          );
        });
      } else {
        messageController.text = sendingContent.value!;
        _hasHandledSharedFile = false;
      }
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void _clearController() {
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    /// Providers
    final chatProvider = Provider.of<ChatProvider>(context);
    final internetProvider = Provider.of<InternetProvider>(context);
    final authProvider = Provider.of<MyAuthProvider>(context);
    final imagePickerProvider = Provider.of<ImagePickerProvider>(context);
    final shareIntentProvider = Provider.of<ShareIntentProvider>(context);

    print("(((((${authProvider.currentUser?.username})))))))");
    // print("********${authProvider.isBlocked}********");

    return PopScope(
      canPop: false,
      child: BackgroundScaffold(
        margin: EdgeInsets.all(0),
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
              StreamBuilder<Map<String, int?>>(
                stream: authProvider.adminUserCountStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                  }
                  final employeeCount = snapshot.data?["admin"] ?? 0;
                  final candidateCount = snapshot.data?["user"] ?? 0;
                  print("===========$employeeCount============");
                  print("============$candidateCount=========");
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("S.K.I.N. App"),
                      Row(
                        spacing: 0.02.sw,
                        children: [
                          Text(
                            "Employee: $employeeCount",
                            style: TextStyle(fontSize: AppStyles.bodyText),
                          ),
                          Text(
                            "Candidate: $candidateCount",
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
            StreamBuilder<List<types.Message>>(
              stream: chatProvider.messagesStream,
              builder: (context, snapshot) {
                final isLoading =
                    snapshot.connectionState == ConnectionState.waiting;
                final messages = snapshot.data ?? [];
                return Chat(
                  emptyState: isLoading
                      ? ChatPlaceholder()
                      : Center(
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
                        ),
                  theme: DefaultChatTheme(
                    sentMessageBodyTextStyle: TextStyle(
                      fontSize: AppStyles.msgText,
                      color: AppStyles.smoke,
                    ),
                    receivedMessageBodyTextStyle:
                        TextStyle(fontSize: AppStyles.msgText),
                    dateDividerMargin: EdgeInsets.all(0.03.sh),
                    dateDividerTextStyle: TextStyle(fontSize: 15),
                    userAvatarTextStyle: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: AppStyles.smoke,
                    ),
                    receivedMessageBodyLinkTextStyle: TextStyle(
                      color: AppStyles.links,
                      decoration: TextDecoration.underline,
                      decorationColor: AppStyles.links,
                    ),
                    inputBackgroundColor: AppStyles.primary,
                    inputTextCursorColor: AppStyles.smoke,
                    inputBorderRadius: BorderRadius.all(Radius.circular(0)),
                    sentMessageBodyLinkTextStyle: TextStyle(
                      color: AppStyles.smoke,
                      decoration: TextDecoration.underline,
                      decorationColor: AppStyles.smoke,
                    ),
                  ),
                  timeFormat: DateFormat("d/MM/yyyy - hh:mm a "),
                  inputOptions: InputOptions(
                    enabled: internetProvider.connectionStatus ==
                            AppStatus.kDisconnected
                        ? false
                        : true,
                    textEditingController: messageController,
                    sendButtonVisibilityMode: SendButtonVisibilityMode.always,
                  ),
                  onMessageLongPress: (context, message) {
                    Showdeletedialog.showDeleteDialog(
                        context, message, chatProvider, authProvider);
                  },
                  onAttachmentPressed: () async {
                    final pickedImagePath =
                        await imagePickerProvider.pickImage();

                    if (pickedImagePath == AppStatus.kSuccess &&
                        imagePickerProvider.selectedImage != null) {
                      final compressedImage = await imagePickerProvider
                          .compressImage(imagePickerProvider.selectedImage!);

                      if (compressedImage != null) {
                        await chatProvider.handleImageMessage(
                            authProvider, compressedImage);
                        await service.sendNotificationToUsers(
                            title: authProvider.currentUser!.uid,
                            content: "sent an image");
                      } else {
                        debugPrint("Image compression failed.");
                      }
                    } else {
                      debugPrint("No image selected.");
                    }
                  },
                  messages: messages,
                  onSendPressed: (message) async {
                    if (internetProvider.connectionStatus == AppStatus.kSlow) {
                      ToastHelper.showErrorToast(
                        context: context,
                        message:
                            "Your internet is slow. Message may be delayed.",
                      );
                      return;
                    }

                    chatProvider.sendMessage(message, authProvider);
                    shareIntentProvider.clear();
                    _clearController();
                    imagePickerProvider.clear();

                    await service.sendNotificationToUsers(
                      title: authProvider.currentUser!.username,
                      content: message.text,
                    );
                  },
                  user: types.User(
                    firstName:
                        authProvider.userName ?? authProvider.formUserName,
                    id: authProvider.uid,
                  ),
                  showUserNames: true,
                  showUserAvatars: true,
                  customBottomWidget: context.watch<MyAuthProvider>().canPost
                      ? null
                      : const SizedBox.shrink(),
                );
              },
            ),

            if (internetProvider.connectionStatus == AppStatus.kDisconnected)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.6),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi_off, size: 48, color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          "No Internet Connection",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Please turn on your internet to continue.",
                          style: TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        CustomButton(
                          text: "Retry",
                          width: 0.4.sw,
                          prefixWidget:
                              Icon(Icons.refresh, color: Colors.white),
                          onPressed: () async {
                            await internetProvider.checkConnectivity();
                          },
                          isLoading: internetProvider.isLoading,
                          loadingColor: AppStyles.smoke,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            /// Upload Progress Overlay
            ValueListenableBuilder<double?>(
              valueListenable: chatProvider.uploadProgressNotifier,
              builder: (context, progress, child) {
                if (progress == null) {
                  return const SizedBox.shrink(); // Hide if there's no progress
                }

                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(16),
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                            SizedBox(width: 16),
                            Text(
                              "${(progress * 100).toStringAsFixed(0)}% uploaded",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 16),
                            IconButton(
                              icon: Icon(Icons.cancel, color: Colors.red),
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
