import 'package:flutter/material.dart';
import 'package:skin_chat_app/helpers/my_navigation.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';
import 'package:skin_chat_app/screens/auth/login_screen.dart';

class BlockDialogBox extends StatelessWidget {
  final MyAuthProvider authProvider;

  const BlockDialogBox({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Account Blocked"),
      content: const Text(
        "Your account has been disabled. Please contact the Administrator.",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog first

            // Use addPostFrameCallback to wait until after pop completes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              MyNavigation.replace(context, const LoginScreen());

              // Delay to allow LoginScreen to render before clearing storage
              Future.delayed(const Duration(milliseconds: 200), () {
                authProvider.signOut();
              });
            });
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}
