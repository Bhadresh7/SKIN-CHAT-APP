import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';
import 'package:skin_chat_app/screens/auth/email_verification_screen.dart';
import 'package:skin_chat_app/screens/profile/basic_details_screen.dart';

import 'login_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<MyAuthProvider>();

    return !authProvider.isLoggedIn
        ? const LoginScreen()
        : !authProvider.isEmailVerified
            ? const EmailVerificationScreen()
            : const BasicDetailsScreen();
  }
}
