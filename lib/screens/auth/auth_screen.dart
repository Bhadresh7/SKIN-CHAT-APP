import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart'
    show MyAuthProvider;

import '../exports.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<MyAuthProvider>();

    if (authProvider.isBlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Show a dialog explaining why they're being logged out
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text("Account Blocked"),
            content: Text(
              "Your account has been blocked by an administrator. "
              "Please contact support for more information.",
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await authProvider.signOut();
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      });
    }

    return _getScreenBasedOnAuth(authProvider);
  }
}

Widget _getScreenBasedOnAuth(MyAuthProvider authProvider) {
  if (!authProvider.isLoggedIn || authProvider.isBlocked) {
    return const LoginScreen();
  }
  if (!authProvider.isEmailVerified) {
    return const EmailVerificationScreen();
  }
  if (!authProvider.hasCompletedBasicDetails) {
    return const BasicDetailsScreen();
  }
  if (!authProvider.hasCompletedImageSetup) {
    return const ImageSetupScreen();
  }
  return HomeScreenVarient2();
}
