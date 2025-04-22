import 'package:flutter/material.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/helpers/local_storage.dart';
import 'package:skin_chat_app/services/user_service.dart';
import 'package:skin_chat_app/modal/users.dart';

class BasicUserDetailsProvider extends ChangeNotifier {
  final UserService _service = UserService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _selectedRole;
  String? get selectedRole => _selectedRole;

  Users? _currentUser;

  Users? get currentUser => _currentUser;

  void selectRole({required String? role}) {
    _selectedRole = role;
    notifyListeners();
  }

  void setLoadingState({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String> saveUserToDbAndLocally(Users user) async {
    try {
      setLoadingState(value: true);
      final result = await _service.saveUser(user: user);
      if (result == AppStatus.kEmailAlreadyExists) {
        return AppStatus.kEmailAlreadyExists;
      }
      if(result == AppStatus.kaadharNoExists){
        return AppStatus.kaadharNoExists;
      }
      await LocalStorage.setString("role", user.role);
      await LocalStorage.setString("email", user.email);
      await LocalStorage.setBool("isLoggedIn", true);

      return AppStatus.kSuccess;
    } catch (e) {
      print(e.toString());
      return AppStatus.kFailed;
    } finally {
      setLoadingState(value: false);
      notifyListeners();
    }
  }

  Future<String> updateUserProfile({
    String? imgUrl,
    String? name,
    required String aadharNumber,
    String? mobile,
    String? dob,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      final result = await _service.updateUserProfile(
        aadharNumber: aadharNumber,
        name: name,
        dob: dob,
        imgUrl: imgUrl,
        mobile: mobile,
      );

      notifyListeners();
      if (result == null) {
        return AppStatus.kFailed;
      }
      return AppStatus.kSuccess;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print(e.toString());
      return AppStatus.kFailed;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
