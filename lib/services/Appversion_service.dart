import 'package:package_info_plus/package_info_plus.dart';

class AppversionService {
  static Future<String> getAppVersion() async {
    final appVersion = await PackageInfo.fromPlatform();
    print("==========${appVersion.version}++++++");
    return appVersion.version;
  }
}
