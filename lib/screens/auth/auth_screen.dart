import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:skin_chat_app/providers/exports.dart' show MyAuthProvider;
import 'package:skin_chat_app/screens/exports.dart'
    show
        LoginScreen,
        EmailVerificationScreen,
        BasicDetailsScreen,
        ImageSetupScreen,
        HomeScreenVarient2;

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<MyAuthProvider>();

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
}
