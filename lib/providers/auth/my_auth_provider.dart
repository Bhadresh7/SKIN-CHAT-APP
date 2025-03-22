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
  String? _formUserName;
  String? _role;
  String _password = '';
  bool hasCompletedBasicDetails = false;
  bool hasCompletedImageSetup = false;
  bool isGoogle = false;
  bool _canPost = false;
  int? _adminCount;
  int? _userCount;
  String? imgUrl;

  int get adminCount => _adminCount ?? 0;
  int get userCount => _userCount ?? 0;
  String get password => _password;
  String get email => _auth.currentUser?.email ?? "no email";
  String? get userName => _auth.currentUser?.displayName;
  String get uid => _auth.currentUser?.uid ?? "uid not found";
  String? get role => _role;
  bool get isLoading => _isLoading;
  bool get canPost => _canPost;
  String get formUserName => _formUserName ?? "no form name";
  Future<bool> get isOauth async => await _googleSignIn.isSignedIn();
  Stream<Map<String, int>> get adminUserCountStream =>
      _service.userAndAdminCountStream;

  MyAuthProvider() {
    _loadUserDetails();
    _initializeEmailVerification();
  }

  /// Load user details
  Future<void> _loadUserDetails() async {
    _role = await LocalStorage.getString("role") ?? "no-role-found";
    _canPost = await LocalStorage.getBool("canPost") ?? false;
    isLoggedIn = await LocalStorage.getBool("isLoggedIn") ?? false;
    isEmailVerified = await LocalStorage.getBool("isEmailVerified") ?? false;
    _formUserName =
        await LocalStorage.getString("userName") ?? "no form userName";
    hasCompletedBasicDetails =
        await LocalStorage.getBool('hasCompletedBasicDetails') ?? false;
    hasCompletedImageSetup =
        await LocalStorage.getBool('hasCompletedImageSetup') ?? false;

    print("👍 isLoggedIn: $isLoggedIn");
    print("🔥 isEmailVerified: $isEmailVerified");
    print("🔹 Role from LocalStorage: $_role");
    print("🔹 CanPost from LocalStorage: $_canPost");

    notifyListeners();

    // Start listening for real-time updates
    _service.fetchRoleAndSaveLocally(email: email).listen(
      (data) async {
        _role = data["role"];
        _canPost = data["canPost"];

        // Ensure updates are stored correctly
        await LocalStorage.setString("role", _role);
        await LocalStorage.setBool("canPost", _canPost);

        print("🔄 Live update - Role: $_role, CanPost: $_canPost");

        notifyListeners();
      },
    );
  }

  void setPassword(String newPassword) {
    _password = newPassword;
    notifyListeners();
  }

  void setLoadingState({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> completeBasicDetails() async {
    await LocalStorage.setBool('hasCompletedBasicDetails', true);
    notifyListeners();
  }

  Future<void> completeImageSetup() async {
    await LocalStorage.setBool('hasCompletedImageSetup', true);
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

      final isEmailExists =
          await _service.findUserByEmail(email: firebaseUser!.email!);
      if (isEmailExists) {
        completeImageSetup();
        await LocalStorage.setBool("isLoggedIn", true);
        await LocalStorage.setBool("isEmailVerified", true);

        final result = await _service.fetchRoleAndCanPostStatus(
            email: firebaseUser!.email!);

        await LocalStorage.setBool('canPost', result['canPost']);
        await LocalStorage.setString('role', result['role']);
        return AppStatus.kEmailAlreadyExists;
      } else {
        completeImageSetup();
        await LocalStorage.setBool("isLoggedIn", true);
        await LocalStorage.setBool("isEmailVerified", true);

        final result = await _service.fetchRoleAndCanPostStatus(
            email: firebaseUser!.email!);

        await LocalStorage.setBool('canPost', result['canPost']);
        await LocalStorage.setString('role', result['role']);

        isGoogle = true;
        return AppStatus.kSuccess;
      }
    } catch (e) {
      print("❌ Error: ${e.toString()}");
      return AppStatus.kFailed;
    } finally {
      setLoadingState(value: false);
    }
  }

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

  /// Login with Email and password
  Future<String> loginWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      setLoadingState(value: true);
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = userCredential.user;
      if (user == null) return AppStatus.kFailed;

      bool isUserExists = await _service.findUserByEmail(email: email);

      if (!isUserExists) {
        return AppStatus.kUserNotFound;
      }
      print("-==-=-=-=-=-=-=-=-=-=-=-=-=-=-${user.displayName}");
      print("==========================${user.email}");
      await LocalStorage.setBool("isLoggedIn", true);
      await LocalStorage.setBool('isEmailVerified', true);
      await LocalStorage.setBool('hasCompletedBasicDetails', true);
      await LocalStorage.setBool('hasCompletedImageSetup', true);

      return AppStatus.kSuccess;
    } catch (e) {
      return e.toString();
    } finally {
      setLoadingState(value: false);
      notifyListeners();
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

  ///dispose timer for email verification
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
}
