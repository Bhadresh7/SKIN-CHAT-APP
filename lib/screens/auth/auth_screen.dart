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

// class AuthScreen extends StatelessWidget {
//   const AuthScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final authProvider = context.watch<MyAuthProvider>();
//     return _getScreenBasedOnAuth(authProvider);
//   }
//
//   Widget _getScreenBasedOnAuth(MyAuthProvider authProvider) {
//     if (!authProvider.isLoggedIn || authProvider.isBlocked) {
//       return const LoginScreen();
//     }
//     if (!authProvider.isEmailVerified) {
//       return const EmailVerificationScreen();
//     }
//     if (!authProvider.hasCompletedBasicDetails) {
//       return const BasicDetailsScreen();
//     }
//     if (!authProvider.hasCompletedImageSetup) {
//       return const ImageSetupScreen();
//     }
//     return HomeScreenVarient2();
//   }
// }
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _cleanupDone = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<MyAuthProvider>();

    if (authProvider.isBlocked && !_cleanupDone) {
      _cleanupDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await authProvider.signOut();
        await authProvider.clearUserDetails();
      });
    }

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
