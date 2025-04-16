import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/helpers/toast_helper.dart';
import 'package:skin_chat_app/providers/exports.dart';
import 'package:skin_chat_app/services/notification_service.dart';
import 'package:skin_chat_app/widgets/buttons/custom_button.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';

class HomeScreenVarient2 extends StatefulWidget {
  const HomeScreenVarient2({super.key});

  @override
  State<HomeScreenVarient2> createState() => _HomeScreenVarient2State();
}

class _HomeScreenVarient2State extends State<HomeScreenVarient2> {
  @override
  void initState() {
    super.initState();

    final internetProvider =
        Provider.of<InternetProvider>(context, listen: false);

    final authProvider = Provider.of<MyAuthProvider>(context, listen: false);
    authProvider.listenToRoleChanges(authProvider.email);
    // Check internet before loading role and messages
    if (internetProvider.connectionStatus == AppStatus.kDisconnected ||
        internetProvider.connectionStatus == AppStatus.kSlow) {
      return;
    }
    authProvider.getUserDetails(email: authProvider.email);
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();

    /// Providers
    final chatProvider = Provider.of<ChatProvider>(context);
    final internetProvider = Provider.of<InternetProvider>(context);
    final authProvider = Provider.of<MyAuthProvider>(context);
    final imagePickerProvider = Provider.of<ImagePickerProvider>(context);
    final shareIntentProvider = Provider.of<ShareIntentProvider>(context);
    // final ValueNotifier<double?> uploadProgressNotifier = ValueNotifier(null);

    final NotificationService service = NotificationService();

    print("(((((${authProvider.currentUser?.username})))))))");
    print("${shareIntentProvider.sharedValues}");
    final sharedText = shareIntentProvider.sharedValues;
    if (sharedText.isNotEmpty) {
      setState(() {
        messageController.text = sharedText.toString();
      });
    }

    /// Show a warning if there is no internet connection
    if (internetProvider.connectionStatus == AppStatus.kDisconnected) {
      return PopScope(
        canPop: false,
        child: BackgroundScaffold(
          showDrawer: true,
          appBar: AppBar(title: const Text("Chat")),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "No internet connection. Please check your network.",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: AppStyles.subTitle,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                CustomButton(
                  isLoading: internetProvider.isLoading,
                  prefixWidget: Icon(Icons.refresh),
                  width: 0.3.sw,
                  text: "Retry",
                  onPressed: () async {
                    await internetProvider.checkConnectivity();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                  final employeeCount = snapshot.data?["admin"] ?? 0;
                  final candidateCount = snapshot.data?["user"] ?? 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("S.K.I.N CHATS"),
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
                final messages = snapshot.data ?? [];
                final sortedMessages = messages
                  ..sort(
                      (a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));

                return Chat(
                  theme: DefaultChatTheme(
                    dateDividerMargin: EdgeInsets.all(0.03.sh),
                    dateDividerTextStyle: TextStyle(fontSize: 15),
                    userNameTextStyle: TextStyle(fontWeight: FontWeight.w700),
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
                      color: AppStyles.links,
                      decoration: TextDecoration.underline,
                      decorationColor: AppStyles.links,
                    ),
                  ),
                  timeFormat: DateFormat("d/MM/yyyy - hh:mm a "),
                  inputOptions: InputOptions(
                    textEditingController: messageController,
                    sendButtonVisibilityMode: SendButtonVisibilityMode.always,
                  ),
                  onMessageLongPress: (context, message) {
                    _showDeleteDialog(
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
                      } else {
                        debugPrint("Image compression failed.");
                      }
                    } else {
                      debugPrint("No image selected.");
                    }
                  },
                  messages: sortedMessages,
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
                    await service.sendNotificationToUsers(
                      title: authProvider.currentUser!.username,
                      content: message.text,
                    );
                    shareIntentProvider.clear();
                    messageController.clear();
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

  void _showDeleteDialog(BuildContext context, dynamic message,
      ChatProvider chatProvider, MyAuthProvider authProvider) {
    if (message.author.id != authProvider.uid) {
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Message"),
        content: const Text("Are you sure you want to delete this message?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await chatProvider.deleteMessage(message.id);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
