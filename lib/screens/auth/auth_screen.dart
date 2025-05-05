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
    return _getScreenBasedOnAuth(authProvider);
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
}
