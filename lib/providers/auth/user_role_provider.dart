import 'package:flutter/foundation.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/helpers/local_storage.dart';

class UserRoleProvider extends ChangeNotifier {
  String? role;

  void loadUserRole() async {
    role = await LocalStorage.getString("role");
    print(role);
    notifyListeners();
  }

  ///get the user role
  String getUserRole({required String role}) {
    return role;
  }

  ///returns true if the role match else false
  bool getChatPermission({required String role}) {
    return role == AppStatus.kSuperAdmin || role == AppStatus.kAdmin;
  }
}
