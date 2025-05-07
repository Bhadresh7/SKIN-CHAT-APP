import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/helpers/local_storage.dart';
import 'package:skin_chat_app/modal/users.dart';
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

  Stream<Map<String, int?>> get adminUserCountStream =>
      _service.userAndAdminCountStream;

  List<Users> allUsers = [];

  MyAuthProvider() {
    _loadUserDetails();
  }

  /// Load user details
  Future<void> _loadUserDetails() async {
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

    print("👍 isLoggedIn: $isLoggedIn");
    print("🔥 isEmailVerified: $isEmailVerified");
    print("🔹 Role from LocalStorage: $_role");
    print("🔹 CanPost from LocalStorage: $_canPost");
    print("🥰 Google Login Status LocalStorage: $isGoogle");

    notifyListeners();

    // Start listening for real-time updates
    _service.fetchRoleAndSaveLocally(email: email).listen(
      (data) async {
        if (_role != data["role"] || _canPost != data["canPost"]) {
          _role = data["role"];
          _canPost = data["canPost"];

          // Only update local storage if values have changed
          await LocalStorage.setString("role", _role);
          await LocalStorage.setBool("canPost", _canPost);

          print("======>>>>> Live update - Role: $_role, CanPost: $_canPost");

          notifyListeners();
        }
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

  /// Google Authentication
  Future<String> googleAuth() async {
    try {
      setLoadingState(value: true);
      notifyListeners();

      print("🔹 Google Sign-In Process Started");

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
      final email = firebaseUser!.email!;

      //check the user is blocked or not
      final roleInfo = await _service.fetchRoleAndCanPostStatus(email: email);
      if (roleInfo['status'] == AppStatus.kBlocked) {
        await _googleSignIn.disconnect();
        return AppStatus.kBlocked;
      }

      print("✅ Firebase User Signed In: ${firebaseUser!.email}");
      isGoogle = true;

      await LocalStorage.setBool("isGoogle", true);
      notifyListeners();

      final isEmailExists = await _service.findUserByEmail(email: email);
      print("🔹 Email exists in system: $isEmailExists");
      if (isEmailExists) {
        await LocalStorage.setBool("isLoggedIn", true);
        await LocalStorage.setBool("isEmailVerified", true);
        await LocalStorage.setBool('hasCompletedBasicDetails', true);
        await LocalStorage.setBool('hasCompletedImageSetup', true);

        notifyListeners();
      }
      print("✅ Role & canPost info: $roleInfo");

      _notificationService.storeDeviceToken(uid: firebaseUser!.uid);

      await LocalStorage.setBool("canPost", roleInfo['canPost'] ?? false);
      await LocalStorage.setString("role", roleInfo['role'] ?? "");

      print("🔹 Stored isGoogle: ${await LocalStorage.getBool('isGoogle')}");
      print("🔹 Stored canPost: ${await LocalStorage.getBool('canPost')}");
      print("🔹 Stored role: ${await LocalStorage.getString('role')}");

      return isEmailExists ? AppStatus.kEmailAlreadyExists : AppStatus.kSuccess;
    } catch (e) {
      print("❌ Error during Google Auth: ${e.toString()}");

      isGoogle = false;
      await LocalStorage.setBool("isGoogle", false);
      notifyListeners();

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

      final result = await _service.isUserExists(username: username);

      if (result) {
        return AppStatus.kUserNameAlreadyExists;
      }

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user == null) return AppStatus.kFailed;

      await user.sendEmailVerification();
      _notificationService.storeDeviceToken(uid: user.uid);
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

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) return AppStatus.kUserNotFound;

      final result = await _service.fetchRoleAndCanPostStatus(email: email);

      if (result['status'] == AppStatus.kBlocked) {
        return AppStatus.kBlocked;
      }

      await LocalStorage.setBool("isLoggedIn", true);
      await LocalStorage.setBool('isEmailVerified', true);
      await LocalStorage.setBool('hasCompletedBasicDetails', true);
      await LocalStorage.setBool('hasCompletedImageSetup', true);
      _notificationService.storeDeviceToken(uid: user.uid);
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

  final FirebaseFirestore _store = FirebaseFirestore.instance;

  /// Listen to user role updates in real-time
  void listenToRoleChanges(String email) {
    _store
        .collection("super_admins")
        .where("email", isEqualTo: email)
        .limit(1)
        .snapshots()
        .listen((superAdminSnapshot) async {
      if (superAdminSnapshot.docs.isNotEmpty) {
        _updateUserData(superAdminSnapshot.docs.first.data());
        return;
      }

      _store
          .collection("users")
          .where("email", isEqualTo: email)
          .limit(1)
          .snapshots()
          .listen((userSnapshot) async {
        if (userSnapshot.docs.isNotEmpty) {
          _updateUserData(userSnapshot.docs.first.data());
        }
      });
    });
  }

  /// Update local storage and notify UI
  Future<void> _updateUserData(Map<String, dynamic> data) async {
    _role = data["role"] ?? "no-role-found";
    _canPost = data["canPost"] ?? false;
    _isBlocked = data["isBlocked"] ?? false;

    await LocalStorage.setString("role", _role);
    await LocalStorage.setBool("canPost", _canPost);
    await LocalStorage.setBool("isBlocked", _isBlocked);
    print("FROM THE PROVIDER BLOCKED STATUS:=$_isBlocked");

    notifyListeners(); // Updates UI
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
      // Sign out from Firebase
      await _auth.signOut();
      await _service.deleteTokenOnSignOut(uid: uid);
      // Disconnect Google if connected
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }
      // Clear local data
      await Future.wait(<Future>[
        LocalStorage.clear(),
        clearUserDetails(),
      ]);

      // Reset user state
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

  void disposeControllers() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}
