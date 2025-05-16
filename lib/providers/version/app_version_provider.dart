import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionProvider with ChangeNotifier {
  String? _appVersion;

  String? get appVersion => _appVersion;

  Future<void> fetchAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    _appVersion = info.version;
    notifyListeners();
  }
}
