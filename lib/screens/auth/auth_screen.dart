import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart'
    show MyAuthProvider;

import '../screen_exports.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _hasHandledBlock = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<MyAuthProvider>();

    if (authProvider.isBlocked && !_hasHandledBlock) {
      _hasHandledBlock = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
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
  print("####################${authProvider.isBlocked}");
  if (!authProvider.isLoggedIn || authProvider.isBlocked) {
    return const LoginScreen();
  } else if (!authProvider.isEmailVerified) {
    return const EmailVerificationScreen();
  } else if (!authProvider.hasCompletedBasicDetails) {
    return const BasicDetailsScreen();
  } else if (!authProvider.hasCompletedImageSetup) {
    return const ImageSetupScreen();
  } else {
    return HomeScreenVarient2();
  }
}
