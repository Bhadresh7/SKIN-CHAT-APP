// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
//
// ;import 'package:skin_chat_app/constants/app_styles.dart';
// import 'package:skin_chat_app/providers/internet/internet_provider.dart';
// import 'package:skin_chat_app/widgets/buttons/custom_button.dart';
//
// import 'background_scaffold.dart';
//
// class NoInternet extends StatefulWidget {
//   const NoInternet({super.key});
//
//   @override
//   State<NoInternet> createState() => _NoInternetState();
// }
//
// class _NoInternetState extends State<NoInternet> {
//
//
//   @override
//   Widget build(BuildContext context) {
//     final internetProvider = Provider.of<InternetProvider>(context);
//     return PopScope(
//       canPop: false,
//       child: BackgroundScaffold(
//         showDrawer: true,
//         appBar: AppBar(title: const Text("Chat")),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 "No internet connection. Please check your network.",
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontSize: AppStyles.subTitle,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 20),
//               CustomButton(
//                 isLoading: internetProvider.isLoading,
//                 prefixWidget: Icon(Icons.refresh),
//                 width: 0.3.sw,
//                 text: "Retry",
//                 onPressed: () async {
//                   await internetProvider.checkConnectivity();
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
