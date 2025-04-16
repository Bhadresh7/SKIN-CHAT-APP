import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/helpers/internet_checker_helper.dart';

class InternetProvider extends ChangeNotifier {
  final InternetConnectionHelper _internetHelper = InternetConnectionHelper();
  String _connectionStatus = "Unknown";

  String get connectionStatus => _connectionStatus;
  bool _isLoading = false;
  get isLoading => _isLoading;

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

  Future<void> checkConnectivity() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(seconds: 2));
    final status = await _internetHelper.getCurrentStatus();
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
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _internetHelper.dispose();
    super.dispose();
  }
}
