import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/models/users_model.dart';
import 'package:skin_chat_app/services/user_service.dart';

class BasicUserDetailsProvider extends ChangeNotifier {
  final _service = UserService();
  StreamSubscription? _userStreamSubscription;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String? _selectedRole;

  String? get selectedRole => _selectedRole;

  void selectRole({required String? role}) {
    _selectedRole = role;
    notifyListeners();
  }

  void setLoadingState({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String> saveUserToDbAndLocally(UsersModel user) async {
    try {
      setLoadingState(value: true);
      final result = await _service.saveUser(user: user);
      _userStreamSubscription = _service.fetchRoleAndSaveLocally().listen(
        (data) async {
          print("First registeration");
          print("Stream data received: $data");
        },
        onError: (error) {
          debugPrint("User stream error: $error");
        },
        onDone: () {
          debugPrint("User stream completed");
        },
      );
      if (result == AppStatus.kEmailAlreadyExists) {
        return AppStatus.kEmailAlreadyExists;
      }

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
    String? mobile,
    String? dob,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      final result = await _service.updateUserProfile(
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
