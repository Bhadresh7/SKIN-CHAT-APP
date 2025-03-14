import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static clear() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.clear();
  }

  static setBool(String key, value) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    return storage.getBool(key);
  }

  static setString(String key, value) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    return storage.getString(key);
  }

  static Future<bool?> removeElement(String key) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    return storage.remove(key);
  }

  static setInt(String key, int value) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    return storage.getInt(key) ?? 0;
  }
}
