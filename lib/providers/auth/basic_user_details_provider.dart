import 'package:flutter/material.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/entity/users.dart';
import 'package:skin_chat_app/helpers/local_storage.dart';
import 'package:skin_chat_app/services/user_service.dart';

class BasicUserDetailsProvider extends ChangeNotifier {
  final UserService _service = UserService();

  Future<String> saveUserToDbAndLocally(Users user) async {
    try {
      await _service.saveUser(user: user);
      await LocalStorage.setString("role", user.role);
      await LocalStorage.setString("email", user.email);
      await LocalStorage.setBool("isLoggedIn", true);
      return AppStatus.kSuccess;
    } catch (e) {
      print(e.toString());
      return AppStatus.kFailed;
    } finally {
      notifyListeners();
    }
  }
}
