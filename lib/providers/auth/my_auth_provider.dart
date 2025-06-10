import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:skin_chat_app/constants/app_hive_constants.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/helpers/local_storage.dart';
import 'package:skin_chat_app/models/users.dart';
import 'package:skin_chat_app/services/hive_service.dart';
import 'package:skin_chat_app/services/notification_service.dart';
import 'package:skin_chat_app/services/user_service.dart';

class MyAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _service = UserService();
  final NotificationService _notificationService = NotificationService();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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
  Users? _currentUser;

  Users? get currentUser => _currentUser;
  bool _isBlocked = false;

  bool get isBlocked => _isBlocked;

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

  Stream<Map<String, dynamic>> get adminUserCountStream =>
      _service.userAndAdminCountStream;

  List<Users> allUsers = [];

  MyAuthProvider() {
    _loadUserDetails();
  }

  /// Load user details
  Future<void> _loadUserDetails() async {
    _currentUser =
        HiveService.userBox.get(AppHiveConstants.kCurrentUserDetails);
    print("++++++++++++++++++++++++++++++++++");
    print(_currentUser.toString());
    print("++++++++++++++++++++++++++++++++++");

    _isBlocked = await LocalStorage.getBool("isBlocked") ?? false;
    _role = await LocalStorage.getString("role") ?? "no-role-found";
    _canPost = await LocalStorage.getBool("canPost") ?? false;
    isLoggedIn = await LocalStorage.getBool("isLoggedIn") ?? false;
    isGoogle = await LocalStorage.getBool("isGoogle") ?? false;
    isEmailVerified = await LocalStorage.getBool("isEmailVerified") ?? false;
    _formUserName =
        await LocalStorage.getString("userName") ?? "no form userName";
    hasCompletedBasicDetails =
        await LocalStorage.getBool('hasCompletedBasicDetails') ?? false;
    hasCompletedImageSetup =
        await LocalStorage.getBool('hasCompletedImageSetup') ?? false;

    if (_currentUser?.email.isNotEmpty ?? false) {
      _service.fetchRoleAndSaveLocally(email: _currentUser?.email ?? "").listen(
        (data) async {
          print("Stream update received: $data");
          _currentUser?.canPost = data["canPost"] ?? false;
          _currentUser?.role = data["role"] ?? "";
          _currentUser?.isBlocked = data["isBlocked"] ?? false;
          _currentUser?.save();

          print("========================");
          print(_currentUser?.email ?? "");
          print("========================");

          notifyListeners();

          if (_currentUser!.isBlocked) {
            await signOut();
            notifyListeners();
          }
        },
        onError: (e) {
          print("Stream error: $e");
        },
      );
      notifyListeners();
    }
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

  /// Google Authentication

  Future<String> googleAuth() async {
    try {
      setLoadingState(value: true);
      notifyListeners();

      print("🔹 Google Sign-In Process Started");
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.disconnect();
      }
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("❌ Google sign-in canceled by user");
        return AppStatus.kFailed;
      }

      print("✅ Google User Signed In: ${googleUser.email}");

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("🔹 Signing in with Google credentials...");
      final userCredential = await _auth.signInWithCredential(credential);
      firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        print("❌ Firebase User is NULL after authentication");
        return AppStatus.kFailed;
      }

      isGoogle = true;
      await LocalStorage.setBool("isGoogle", true);
      notifyListeners();
      _currentUser =
          await _service.getUserDetailsByEmail(email: googleUser.email);

      HiveService.saveUserToHive(user: _currentUser);

      if (_currentUser?.isBlocked ?? false) {
        return AppStatus.kBlocked;
      }

      if (_currentUser != null) {
        await LocalStorage.setBool("isLoggedIn", true);
        await LocalStorage.setBool("isEmailVerified", true);
        await LocalStorage.setBool('hasCompletedBasicDetails', true);
        await LocalStorage.setBool('hasCompletedImageSetup', true);
      }

      await LocalStorage.setBool("canPost", _canPost);
      await LocalStorage.setString("role", _role ?? "");

      _notificationService.storeDeviceToken(uid: uid);
      notifyListeners();

      return _currentUser != null
          ? AppStatus.kEmailAlreadyExists
          : AppStatus.kSuccess;
    } catch (e) {
      print("❌ Error during Google Auth: ${e.toString()}");
      isGoogle = false;
      await LocalStorage.setBool("isGoogle", false);
      return AppStatus.kFailed;
    } finally {
      setLoadingState(value: false);
      notifyListeners();
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

      final result = await _service.isUserNameExists(username: username);

      if (result) {
        return AppStatus.kUserNameAlreadyExists;
      }

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user == null) return AppStatus.kFailed;

      await user.sendEmailVerification();
      _notificationService.storeDeviceToken(uid: uid);
      await LocalStorage.setString("userName", username);
      _formUserName = username;
      await LocalStorage.setBool('isLoggedIn', true);
      return AppStatus.kSuccess;
    } on FirebaseAuthException catch (e) {
      if (e.code == AppStatus.kEmailAlreadyExists) {
        return AppStatus.kEmailAlreadyExists;
      }
      return e.message ?? "An unknown error occurred.";
    } catch (e) {
      return "Error: $e";
    } finally {
      setLoadingState(value: false);
    }
  }

  /// Login with Email and password
  Future<String> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      setLoadingState(value: true);

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUser = await _service.getUserDetailsByEmail(email: email);
      if (_currentUser == null) return AppStatus.kUserNotFound;

      final result = await _service.fetchRoleAndCanPostStatus(email: email);

      if (result['status'] == AppStatus.kBlocked) {
        return AppStatus.kBlocked;
      }

      _role = result['role'];
      _canPost = result['canPost'];

      print("PPPPPPPPPPPPPPPPPPP$_role");
      print("OOOOOOOOOOOO$_canPost");

      await LocalStorage.setBool("isLoggedIn", true);
      await LocalStorage.setBool('isEmailVerified', true);
      await LocalStorage.setBool('hasCompletedBasicDetails', true);
      await LocalStorage.setBool('hasCompletedImageSetup', true);
      _notificationService.storeDeviceToken(uid: uid);
      return AppStatus.kSuccess;
    } on FirebaseAuthException catch (e) {
      print(e.code);
      print("============================");
      switch (e.code) {
        case "invalid-credential":
          return AppStatus.kInvalidCredential;
        default:
          return AppStatus.kFailed;
      }
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
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> clearUserDetails() async {
    await LocalStorage.removeElement("role");
    await LocalStorage.removeElement("canPost");
    await LocalStorage.removeElement("isLoggedIn");
    await LocalStorage.removeElement("isEmailVerified");
    await LocalStorage.removeElement("userName");
    await LocalStorage.removeElement("hasCompletedBasicDetails");
    await LocalStorage.removeElement("hasCompletedImageSetup");

    // Reset variables
    _role = "no-role-found";
    _canPost = false;
    isLoggedIn = false;
    isEmailVerified = false;
    _formUserName = "no form userName";
    hasCompletedBasicDetails = false;
    hasCompletedImageSetup = false;

    print("🗑️ User details cleared from LocalStorage");
    print("🔹 Role: $_role");
    print("🔹 CanPost: $_canPost");
    print("👍 isLoggedIn: $isLoggedIn");
    print("🔥 isEmailVerified: $isEmailVerified");
    print("📛 UserName: $_formUserName");
    print("✅ hasCompletedBasicDetails: $hasCompletedBasicDetails");
    print("🖼️ hasCompletedImageSetup: $hasCompletedImageSetup");

    notifyListeners();
  }

  Future<Users?> getUserDetails({required String email}) async {
    try {
      final user = await _service.getUserDetailsByEmail(email: email);

      if (user != null) {
        _currentUser = user;
        print("User loaded: $_currentUser");
        notifyListeners();
      } else {
        print("User not found");
      }

      return user;
    } catch (e) {
      print("Provider error: ${e.toString()}");
      return null;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      var box = await Hive.openBox<Users>(AppHiveConstants.kUserBox);
      await box.clear();

      if (box.isEmpty) {
        print("User Details Cleared");
      } else {
        print("User Details not Cleared");
      }
      // Sign out from Firebase
      await _service.deleteTokenOnSignOut(uid: uid);
      await _auth.signOut();
      // Disconnect Google if connected
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }
      // Clear local data
      await Future.wait(<Future>[
        LocalStorage.clear(),
        clearUserDetails(),
      ]);

      _currentUser = null;
      _role = null;

      print("User signed out successfully");
    } catch (e) {
      print("Error signing out: $e");
    } finally {
      notifyListeners();
    }
  }

  void clearControllers() {
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    notifyListeners();
  }
}
