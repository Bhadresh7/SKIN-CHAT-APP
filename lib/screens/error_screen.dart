// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:skin_chat_app/constants/app_assets.dart';
// import 'package:skin_chat_app/constants/app_styles.dart';
// import 'package:skin_chat_app/widgets/common/background_scaffold.dart';
//
// class ErrorScreen extends StatelessWidget {
//   const ErrorScreen({super.key, required this.errorDetails});
//
//   final FlutterErrorDetails errorDetails;
//
//   @override
//   Widget build(BuildContext context) {
//     return BackgroundScaffold(
//       body: Center(
//           child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             "Please contact the developer",
//             style: TextStyle(fontSize: AppStyles.heading),
//           ),
//           Text(errorDetails.toString()),
//           Lottie.asset(
//             AppAssets.developerLottie,
//           ),
//         ],
//       )),
//     );
//   }
// }
