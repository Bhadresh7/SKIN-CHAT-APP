import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppApis {
  static String get baseUrl => dotenv.get("BASE_URL", fallback: "NO-URL-FOUND");
  static String getNotification = "$baseUrl/sendnotification";
}
