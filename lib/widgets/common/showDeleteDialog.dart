import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show AlertDialog, Colors, TextButton, showDialog;

import '../../providers/auth/my_auth_provider.dart' show MyAuthProvider;
import '../../providers/message/chat_provider.dart' show ChatProvider;

class ShowDeleteDialog {
  static void showDeleteDialog(BuildContext context, dynamic message,
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
              print(")))))))))))))))))))))))))");
              print(message.id);
              print(")))))))))))))))))))))))))");

              await chatProvider.deleteMessage(message.id);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
