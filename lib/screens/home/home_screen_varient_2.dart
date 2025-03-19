import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/helpers/toast_helper.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';
import 'package:skin_chat_app/providers/auth/user_role_provider.dart';
import 'package:skin_chat_app/providers/internet_provider.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';

import '../../constants/app_status.dart';
import '../../providers/message/chat_provider.dart';

class HomeScreenVarient2 extends StatefulWidget {
  const HomeScreenVarient2({super.key});

  @override
  State<HomeScreenVarient2> createState() => _HomeScreenVarient2State();
}

class _HomeScreenVarient2State extends State<HomeScreenVarient2> {
  @override
  void initState() {
    super.initState();
    final roleProvider = Provider.of<UserRoleProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final internetProvider =
        Provider.of<InternetProvider>(context, listen: false);

    // Check internet before loading role and messages
    if (internetProvider.connectionStatus != AppStatus.kDisconnected ||
        internetProvider.connectionStatus != AppStatus.kSlow) {
      roleProvider.loadUserRole();
      chatProvider.listenForMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Providers
    final authProvider = Provider.of<MyAuthProvider>(context);
    final userRoleProvider = Provider.of<UserRoleProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final internetProvider = Provider.of<InternetProvider>(context);

    /// Show a warning if there is no internet connection
    if (internetProvider.connectionStatus == AppStatus.kDisconnected) {
      return BackgroundScaffold(
        showDrawer: true,
        appBar: AppBar(title: const Text("Chat")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "No internet connection. Please check your network.",
                style:
                    TextStyle(color: Colors.red, fontSize: AppStyles.subTitle),
              ),
            ],
          ),
        ),
      );
    }

    /// Sort messages (newest at the bottom)
    final sortedMessages = List<types.Message>.from(chatProvider.messages)
      ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));

    return BackgroundScaffold(
      margin: EdgeInsets.all(0),
      showDrawer: true,
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      body: Chat(
        messages: sortedMessages,
        onSendPressed: userRoleProvider.role == AppStatus.kUser
            ? (_) {}
            : (message) {
                if (internetProvider.connectionStatus == AppStatus.kSlow) {
                  return ToastHelper.showErrorToast(
                    context: context,
                    message: "Your internet is slow. Message may be delayed.",
                  );
                }
                chatProvider.sendMessage(message, authProvider);
              },
        user: types.User(id: authProvider.uid),
        customBottomWidget: userRoleProvider.role == AppStatus.kUser
            ? const SizedBox.shrink()
            : null,
      ),
    );
  }
}
