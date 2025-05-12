import 'package:flutter/services.dart';

class FileResolver {
  static const MethodChannel _channel =
      MethodChannel('com.chat.skin_chat_app/file_resolver');

  static Future<String?> resolveFilePath(String contentUri) async {
    try {
      final String? path =
          await _channel.invokeMethod('resolveFilePath', {'uri': contentUri});
      return path;
    } catch (e) {
      print("Error resolving content URI: $e");
      return null;
    }
  }
}
