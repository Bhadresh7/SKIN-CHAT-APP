import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/helpers/internet_checker_helper.dart';

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
          _connectionStatus = AppStatus.kConnected;
          break;
        case InternetConnectionStatus.disconnected:
          _connectionStatus = AppStatus.kDisconnected;
          break;
        case InternetConnectionStatus.slow:
          _connectionStatus = AppStatus.kSlow;
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
