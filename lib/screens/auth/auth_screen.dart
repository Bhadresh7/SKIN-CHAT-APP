import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';
import 'package:skin_chat_app/screens/auth/email_verification_screen.dart';
import 'package:skin_chat_app/screens/home/home_screen_varient_2.dart';
import 'package:skin_chat_app/screens/profile/basic_details_screen.dart';
import 'package:skin_chat_app/screens/profile/image_setup_screen.dart';

import 'login_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<MyAuthProvider>();

    if (!authProvider.isLoggedIn) {
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
