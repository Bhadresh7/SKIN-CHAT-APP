import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
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
  String? _role;

  String get email => _auth.currentUser?.email ?? "no email";
  String get userName => _auth.currentUser?.displayName ?? "no username";
  String get uid => _auth.currentUser?.uid ?? "uid not found";
  String? get role => _role;
  bool get isLoading => _isLoading;

  Future<bool> get isOauth async => await _googleSignIn.isSignedIn();

  MyAuthProvider() {
    _loadUserDetails();
    _initializeEmailVerification();
  }

  void setLoadingState({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  /// Load user details
  Future<void> _loadUserDetails() async {
    isLoggedIn = await LocalStorage.getBool("isLoggedIn") ?? false;
    isEmailVerified = await LocalStorage.getBool("isEmailVerified") ?? false;

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

      // await _saveUserSession(firebaseUser!);
      return AppStatus.kSuccess;
    } catch (e) {
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

      if (!user.emailVerified) {
        await user.sendEmailVerification();
        return AppStatus.kEmailNotVerified;
      }

      // // await _saveUserSession(user);
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
