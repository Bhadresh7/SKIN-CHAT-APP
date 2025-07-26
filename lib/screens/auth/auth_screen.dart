// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:skin_chat_app/providers/auth/my_auth_provider.dart'
//     show MyAuthProvider;
// import 'package:skin_chat_app/services/hive_service.dart';
//
// import '../screen_exports.dart';
//
// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});
//
//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }
//
// class _AuthScreenState extends State<AuthScreen> {
//   bool _hasHandledBlock = false;
//   bool _isShowingBlockDialog = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final authProvider = context.watch<MyAuthProvider>();
//
//     bool isBlocked = (authProvider.currentUser?.isBlocked ?? false) ||
//         (HiveService.getCurrentUser()?.isBlocked ?? false);
//
//     // Handle blocked user case
//     if (isBlocked &&
//         authProvider.isLoggedIn &&
//         !_hasHandledBlock &&
//         !_isShowingBlockDialog) {
//       _hasHandledBlock = true;
//       _isShowingBlockDialog = true;
//
//       WidgetsBinding.instance.addPostFrameCallback(
//         (_) async {
//           if (mounted) {
//             await _showBlockedDialog(context, authProvider);
//           }
//         },
//       );
//     }
//
//     // Reset flags when user is not blocked
//     if (!isBlocked) {
//       _hasHandledBlock = false;
//       _isShowingBlockDialog = false;
//     }
//
//     return _getScreenBasedOnAuth(authProvider);
//   }
//
//   Future<void> _showBlockedDialog(
//       BuildContext context, MyAuthProvider authProvider) async {
//     try {
//       await showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => AlertDialog(
//           title: const Text("Account Blocked"),
//           content: const Text(
//             "Your account has been blocked by an administrator. "
//             "Please contact support for more information.",
//           ),
//           actions: [
//             TextButton(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 await authProvider.signOut();
//                 _hasHandledBlock = false;
//                 _isShowingBlockDialog = false;
//               },
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       print("Error showing blocked dialog: $e");
//       _hasHandledBlock = false;
//       _isShowingBlockDialog = false;
//     }
//   }
// }
//
// Widget _getScreenBasedOnAuth(MyAuthProvider authProvider) {
//   bool isLoggedIn = authProvider.isLoggedIn;
//
//   bool isBlocked = (authProvider.currentUser?.isBlocked ?? false) ||
//       (HiveService.getCurrentUser()?.isBlocked ?? false);
//
//   bool? basicDetailsFormStatus = authProvider.hasCompletedBasicDetails;
//   bool? imageSetupStatus = authProvider.hasCompletedImageSetup;
//
//   // If user is blocked, always show login screen
//   if (isBlocked) {
//     return const LoginScreen();
//   }
//
//   if (!isLoggedIn) {
//     return const LoginScreen();
//   } else if (!authProvider.isEmailVerified) {
//     return const EmailVerificationScreen();
//   } else if (!basicDetailsFormStatus) {
//     return const BasicDetailsScreen();
//   } else if (!imageSetupStatus) {
//     return const ImageSetupScreen();
//   } else {
//     return HomeScreenVarient2();
//   }
// }
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
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<MyAuthProvider>();
    return _getScreenBasedOnAuth(authProvider);
  }
}

Widget _getScreenBasedOnAuth(MyAuthProvider authProvider) {
  bool isLoggedIn = authProvider.isLoggedIn;
  bool? basicDetailsFormStatus = authProvider.hasCompletedBasicDetails;
  bool? imageSetupStatus = authProvider.hasCompletedImageSetup;

  if (!isLoggedIn) {
    return const LoginScreen();
  } else if (!authProvider.isEmailVerified) {
    return const EmailVerificationScreen();
  } else if (!basicDetailsFormStatus) {
    return const BasicDetailsScreen();
  } else if (!imageSetupStatus) {
    return const ImageSetupScreen();
  } else {
    return HomeScreenVarient2();
  }
}
