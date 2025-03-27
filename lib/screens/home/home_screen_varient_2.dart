import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/helpers/toast_helper.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';
import 'package:skin_chat_app/providers/image_picker_provider.dart';
import 'package:skin_chat_app/providers/internet_provider.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';

import '../../constants/app_status.dart';
import '../../providers/message/chat_provider.dart';
import '../../providers/message/share_intent_provider.dart';

class HomeScreenVarient2 extends StatefulWidget {
  const HomeScreenVarient2({super.key});

  @override
  State<HomeScreenVarient2> createState() => _HomeScreenVarient2State();
}

class _HomeScreenVarient2State extends State<HomeScreenVarient2> {
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();

    final internetProvider =
        Provider.of<InternetProvider>(context, listen: false);

    // Check internet before loading role and messages
    if (internetProvider.connectionStatus != AppStatus.kDisconnected ||
        internetProvider.connectionStatus != AppStatus.kSlow) {
      return;
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _messageController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    /// Providers
    final chatProvider = Provider.of<ChatProvider>(context);
    final internetProvider = Provider.of<InternetProvider>(context);
    final authProvider = Provider.of<MyAuthProvider>(context);
    final imagePickerProvider = Provider.of<ImagePickerProvider>(context);
    final shareIntentProvider = Provider.of<ShareIntentProvider>(context);

    print("${shareIntentProvider.sharedValues}");

    // Set shared text if available
    if (shareIntentProvider.sharedValues.isNotEmpty &&
        _messageController.text.isEmpty) {
      _messageController.text = shareIntentProvider.sharedValues.toString();
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
                      color: Colors.red, fontSize: AppStyles.subTitle),
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
            children: [
              CircleAvatar(
                radius: 0.03.sh,
                child: Image.asset(AppAssets.logo),
              ),
              SizedBox(width: 0.02.sw),
              StreamBuilder<Map<String, int>>(
                stream: authProvider.adminUserCountStream,
                builder: (context, snapshot) {
                  final employeeCount = snapshot.data?["admin"] ?? 0;
                  final candidateCount = snapshot.data?["user"] ?? 0;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                  );
                },
              )
            ],
          ),
        ),
        body: StreamBuilder<List<types.Message>>(
          stream: chatProvider.messagesStream,
          builder: (context, snapshot) {
            /// sort the messages
            final messages = snapshot.data ?? [];
            final sortedMessages = messages
              ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
            return Chat(
              inputOptions: InputOptions(
                textEditingController: _messageController,
              ),
              onAttachmentPressed: () async {
                await imagePickerProvider.pickImage();
              },
              onMessageLongPress: (context, message) {
                _showDeleteDialog(context, message, chatProvider);
              },
              messages: sortedMessages,
              onSendPressed: (message) {
                if (internetProvider.connectionStatus == AppStatus.kSlow) {
                  ToastHelper.showErrorToast(
                    context: context,
                    message: "Your internet is slow. Message may be delayed.",
                  );
                  return;
                }

                chatProvider.sendMessage(message, authProvider);

                shareIntentProvider.clear();
                _messageController.clear();
              },
              user: types.User(
                firstName: authProvider.userName ?? authProvider.formUserName,
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
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, types.Message message, ChatProvider chatProvider) {
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
