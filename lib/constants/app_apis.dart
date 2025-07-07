import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:skin_chat_app/constants/app_config.dart';

class AppApis {
  static String get _baseUrl => AppConfig.isProd
      ? dotenv.get("BASE_URL", fallback: "NO-PROD-URL-FOUND")
      : dotenv.get("TEST_BASE_URL", fallback: "NO-TEST-URL-FOUND");

  static String getNotification = "$_baseUrl/send";

  static String get encryptionKey =>
      dotenv.get("HIVE_ENCRYPTION_KEY", fallback: "NO-KEY-FOUND");
}
