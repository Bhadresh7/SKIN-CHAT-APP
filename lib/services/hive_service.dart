import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:skin_chat_app/constants/app_hive_constants.dart';
import 'package:skin_chat_app/models/users.dart';

class HiveService {
  static late Box<Users> userBox;
  static late Box authBox;
  // static late Box authBox;
  static Future<void> init() async {
    // init hive
    await Hive.initFlutter();
    // register the user adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UsersAdapter());
    }
    //Boxes
    userBox = await Hive.openBox<Users>(AppHiveConstants.kUserBox);
    authBox = await Hive.openBox(AppHiveConstants.kAuthBox);
  }

  static Future<void> saveUserToHive({required Users? user}) async {
    try {
      final box = await Hive.openBox<Users>(AppHiveConstants.kUserBox);
      if (!box.isOpen) {
        debugPrint("User Box is not opened yet !!!!");
        return;
      }
      await box.put(AppHiveConstants.kCurrentUserDetails, user!);
      print(user.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Users? getCurrentUser() {
    try {
      final currentUser = userBox.get(AppHiveConstants.kCurrentUserDetails);
      if (currentUser != null) {
        return currentUser;
      }
      return null;
    } catch (e) {
      print(e.toString());
    }
    return null;
  }
}
