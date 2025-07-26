import 'package:flutter/material.dart';
import 'package:skin_chat_app/constants/app_status.dart';

import '../../providers/auth/my_auth_provider.dart';
import '../../providers/message/chat_provider.dart';

class ShowDeleteDialog {
  static void showDeleteDialog(
    BuildContext context,
    dynamic message,
    ChatProvider chatProvider,
    MyAuthProvider authProvider,
  ) {
    final currentUser = authProvider.currentUser;
    final isAuthor = message.author.id == authProvider.uid;
    final isSuperAdmin = currentUser?.role == AppStatus.kSuperAdmin;

    // Only allow delete if user is the sender or a super admin
    if (!(isAuthor || isSuperAdmin)) return;

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
              await chatProvider.deleteMessage(
                messageId: message.id,
                userId: currentUser?.uid ?? "",
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
