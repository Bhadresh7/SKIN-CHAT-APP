import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/helpers/local_storage.dart';
import 'package:skin_chat_app/services/user_service.dart';

class MyAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _service = UserService();
  User? firebaseUser;
  Timer? _timer;

  bool isLoggedIn = false;
  bool _isLoading = false;
  bool isEmailVerified = false;
  String? _formUserName;
  String? _role;
  String _password = '';
  bool hasCompletedBasicDetails = false;
  bool hasCompletedImageSetup = false;
  bool isGoogle = false;

  String get password => _password;
  String get email => _auth.currentUser?.email ?? "no email";
  String? get userName => _auth.currentUser?.displayName;
  String get uid => _auth.currentUser?.uid ?? "uid not found";
  String? get role => _role;
  bool get isLoading => _isLoading;
  String get formUserName => _formUserName ?? "no form name";
  Future<bool> get isOauth async => await _googleSignIn.isSignedIn();
  String? imgUrl;

  MyAuthProvider() {
    _loadUserDetails();
    _initializeEmailVerification();
  }

  void setPassword(String newPassword) {
    _password = newPassword;
    notifyListeners();
  }

  void setLoadingState({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String?> getUserProfileImage(String userId) async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(userId)
        .child("img")
        .get();

    imgUrl = snapshot.value.toString();
    return imgUrl;
  }

  Future<void> completeBasicDetails() async {
    await LocalStorage.setBool('hasCompletedBasicDetails', true);
    notifyListeners();
  }

  Future<void> completeImageSetup() async {
    await LocalStorage.setBool('hasCompletedImageSetup', true);
  }

  /// Load user details
  Future<void> _loadUserDetails() async {
    isLoggedIn = await LocalStorage.getBool("isLoggedIn") ?? false;
    isEmailVerified = await LocalStorage.getBool("isEmailVerified") ?? false;
    _formUserName =
        await LocalStorage.getString("userName") ?? "no form userName";
    hasCompletedBasicDetails =
        await LocalStorage.getBool('hasCompletedBasicDetails') ?? false;
    hasCompletedImageSetup =
        await LocalStorage.getBool('hasCompletedImageSetup') ?? false;

    print("👍👍👍👍👍👍👍👍$isLoggedIn");
    print("🔥🔥🔥🔥🔥🔥🔥🔥$isEmailVerified");
    _service.fetchRoleAndSaveLocally(email: email).listen((newRow) {
      _role = newRow;
    });

    notifyListeners();
  }

  /// Initialize email verification
  void _initializeEmailVerification() {
    isEmailVerified = _auth.currentUser?.emailVerified ?? false;
    if (!isEmailVerified) {
      _auth.currentUser?.sendEmailVerification();
      _timer = Timer.periodic(
          const Duration(seconds: 3), (_) => checkEmailVerified());
    }
  }

  Future<void> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    if (_auth.currentUser?.emailVerified ?? false) {
      await LocalStorage.setBool("isLoggedIn", true);
      await LocalStorage.setBool("isEmailVerified", true);

      // Print to debug
      print(
          "🔄 Storing isLoggedIn: ${await LocalStorage.getBool("isLoggedIn")}");
      print(
          "🔄 Storing isEmailVerified: ${await LocalStorage.getBool("isEmailVerified")}");

      isLoggedIn = true;
      isEmailVerified = true;

      _timer?.cancel();
      notifyListeners();
    }
  }

  Future<void> resendEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  /// Google Authentication
  Future<String> googleAuth() async {
    try {
      setLoadingState(value: true);
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return AppStatus.kFailed;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      firebaseUser = userCredential.user;
      if (firebaseUser == null) return AppStatus.kFailed;

      final isEmailExists = await _service.findUserByEmail(email: email);
      if (isEmailExists) {
        await LocalStorage.setBool("isLoggedIn", true);
        await LocalStorage.setBool("isEmailVerified", true);
        print("aksdjfak;lsdjf;alkhs");
        return AppStatus.kEmailAlreadyExists;
      }
      await LocalStorage.setBool("isLoggedIn", true);
      await LocalStorage.setBool("isEmailVerified", true);
      isGoogle = true;
      return AppStatus.kSuccess;
    } catch (e) {
      print("❌ Error: ${e.toString()}");
      return AppStatus.kFailed;
    } finally {
      setLoadingState(value: false);
    }
  }

  // Future<void> _saveUserSession(User user) async {
  //   await LocalStorage.setString("user_email", user.email ?? "");
  //   await LocalStorage.setBool("isLoggedIn", true);
  //   notifyListeners();
  // }

  /// Email and Password Registration
  Future<String> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      setLoadingState(value: true);
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user == null) return AppStatus.kFailed;

      await user.sendEmailVerification();
      await LocalStorage.setString("userName", username);
      _formUserName = username;
      return AppStatus.kSuccess;
    } catch (e) {
      return e.toString();
    } finally {
      setLoadingState(value: false);
    }
  }

  /// Login with Email Verification Check
  Future<String> loginWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      setLoadingState(value: true);
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = userCredential.user;
      if (user == null) return AppStatus.kFailed;

      String? role = await _service.findUserRoleByEmail(email: email);
      print("================================$role");
      // if (!isUserExists) {
      //   return AppStatus.kUserNotFound;
      // }
      // // // await _saveUserSession(user);
      // print("==========================${user.email}");
      // var result = await LocalStorage.getBool("isLoggedIn");
      // print("===============================$result");
      return AppStatus.kSuccess;
    } catch (e) {
      return e.toString();
    } finally {
      setLoadingState(value: false);
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }
      await LocalStorage.clear();
      notifyListeners();
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  /// Reset Password
  Future<String> resetPassword({required String email}) async {
    try {
      await _auth.setLanguageCode("en");
      await _auth.sendPasswordResetEmail(email: email);
      return AppStatus.kSuccess;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Future<String> saveUsersToDatabaseAndLocally() async {
//   if (await _googleSignIn.isSignedIn()) {
//     Users userObj = Users(
//       uid: firebaseUser!.uid,
//       username: firebaseUser?.email ?? "",
//       email: firebaseUser?.email ?? "",
//       role: "user",
//       canPost: false,
//       isAdmin: false,
//       isBlocked: false,
//       isGoogle: true,
//     );
//
//     await _service.saveUser(user: userObj);
//     await LocalStorage.setString("role", "user");
//     await LocalStorage.setString("user_email", firebaseUser?.email ?? "");
//     await LocalStorage.setBool("isLoggedIn", true);
//     return AppStatus.kSuccess;
//   } else {}
// }

///check the user role

// String? _userEmail;
//
// String? get userEmail => _userEmail;
//
// void setEmail(String email) {
//   _userEmail = email;
//   notifyListeners();
// }
//
// Future<void> fetchUserRole() async {
//   if (_userEmail == null) return;
//   _role = await _service.fetchRoleAndSaveLocally(email: _userEmail!);
//   notifyListeners();
// }
// }
