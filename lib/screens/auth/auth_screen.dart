import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth/my_auth_provider.dart' show MyAuthProvider;
import '../exports.dart';

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
