// import 'package:flutter/foundation.dart';
// import 'package:skin_chat_app/helpers/internet_checker_helper.dart';
//
// class InternetProvider extends ChangeNotifier {
//   late InternetConnectionHelper _helper;
//
// /*  String? checkConnectivity() {
//     _helper = InternetConnectionHelper();
//     _helper.startListening();
//     if (_helper.currentStatus == AppStatus.connected) {
//       print("Hello there");
//       return AppStatus.connected;
//     } else if (_helper.currentStatus == AppStatus.disconnected) {
//       print("akdjfa;lsdjfa;lkdjf");
//       return AppStatus.disconnected;
//     } else if (_helper.currentStatus == AppStatus.slow) {
//       return AppStatus.slow;
//     } else {
//       print("Something went wrong while connecting to the internet");
//       return "Something went worng";
//     }
//   }*/
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     _helper.dispose();
//   }
// }
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:skin_chat_app/constants/app_status.dart';

import '../helpers/internet_checker_helper.dart';

class InternetProvider extends ChangeNotifier {
  final InternetConnectionHelper _internetHelper = InternetConnectionHelper();
  String _connectionStatus = "Unknown";

  String get connectionStatus => _connectionStatus;

  InternetProvider() {
    _startListening();
  }

  void _startListening() {
    _internetHelper.connectionStatusStream
        .listen((InternetConnectionStatus status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          _connectionStatus = AppStatus.connected;
          break;
        case InternetConnectionStatus.disconnected:
          _connectionStatus = AppStatus.disconnected;
          break;
        case InternetConnectionStatus.slow:
          _connectionStatus = AppStatus.slow;
          break;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _internetHelper.dispose();
    super.dispose();
  }
}
