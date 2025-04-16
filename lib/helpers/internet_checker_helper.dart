import 'dart:async';

import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetConnectionHelper {
  final InternetConnectionChecker _checker =
      InternetConnectionChecker.createInstance();
  StreamSubscription<InternetConnectionStatus>? _subscription;

  Stream<InternetConnectionStatus> get connectionStatusStream {
    return _checker.onStatusChange;
  }

  void startListening() {
    _subscription = connectionStatusStream.listen(
      (InternetConnectionStatus status) {
        switch (status) {
          case InternetConnectionStatus.connected:
            print("Internet is connected");
            break;
          case InternetConnectionStatus.disconnected:
            print("Internet is disconnected");
            break;
          case InternetConnectionStatus.slow:
            print("Slow");
        }
      },
    );
  }

  Future<InternetConnectionStatus> getCurrentStatus() async {
    return await _checker.connectionStatus;
  }

  void dispose() {
    _subscription?.cancel();
  }
}
