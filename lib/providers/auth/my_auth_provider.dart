import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/models/users.dart';
import 'package:skin_chat_app/providers/message/chat_provider.dart';
import 'package:skin_chat_app/services/hive_service.dart';
import 'package:skin_chat_app/services/notification_service.dart';
import 'package:skin_chat_app/services/user_service.dart';

class MyAuthProvider extends ChangeNotifier {
  // Core services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService();
  final NotificationService _notificationService = NotificationService();

  // Controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // State variables
  Users? _currentUser;
  Timer? _timer;
  bool _isLoading = false;
  StreamSubscription? _userStreamSubscription;

  // Getters
  Users? get currentUser => _currentUser;

  bool get isLoading => _isLoading;

  bool get isLoggedIn => HiveService.isLoggedIn;

  bool get isEmailVerified => HiveService.isEmailVerified;

  bool get hasCompletedBasicDetails => HiveService.hasCompletedBasicDetails;

  bool get hasCompletedImageSetup => HiveService.hasCompletedImageSetup;

  bool get isGoogle => HiveService.isGoogle;

  String get uid => _auth.currentUser?.uid ?? "";

  String get email => _auth.currentUser?.email ?? "";

  String? get userName => _auth.currentUser?.displayName;

  // Constructor
  MyAuthProvider() {
    _initialize();
  }

  /// Initialize the provider
  Future<void> _initialize() async {
    await _loadUserFromHive();
  }

  /// Load user details from Hive
  Future<void> _loadUserFromHive() async {
    try {
      _currentUser = HiveService.getCurrentUser();

      if (_currentUser?.email.isNotEmpty ?? false) {
        _setupUserStream();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user from Hive: $e');
    }
  }

  void _setupUserStream() {
    ChatProvider().initMessageStream();

    print("User stream triggered !!!!!!!!!!!");
    _userStreamSubscription?.cancel();

    if (_currentUser?.email == null || _currentUser!.email.isEmpty) {
      debugPrint("No user email available for stream setup");
      return;
    }

    _userStreamSubscription =
        _userService.fetchRoleAndSaveLocally(email: _currentUser!.email).listen(
      (data) async {
        print("Stream data received: $data");
        await _updateUserFromStream(data);
      },
      onError: (error) {
        debugPrint("User stream error: $error");
        // Consider retry logic or fallback mechanism
      },
      onDone: () {
        debugPrint("User stream completed");
      },
    );

    print("Current user: ${_currentUser.toString()}");
  }

  /// Update user from stream data
  Future<void> _updateUserFromStream(Map<String, dynamic> data) async {
    if (_currentUser == null) return;

    _currentUser!.canPost = data["canPost"] ?? false;
    _currentUser!.role = data["role"] ?? "";
    _currentUser!.isBlocked = data["isBlocked"] ?? false;

    print("+++++++++++++++++++++ UDPATE USER STREAM IS CALLED $_currentUser ");
    await HiveService.saveUserToHive(user: _currentUser);
    notifyListeners();

    if (_currentUser!.isBlocked) {
      await signOut();
    }
  }

  /// Set loading state
  void _setLoadingState(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Google Authentication
  Future<String> signInWithGoogle() async {
    try {
      _setLoadingState(true);

      // Sign out any existing Google user
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.disconnect();
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AppStatus.kFailed;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      if (userCredential.user == null) {
        return AppStatus.kFailed;
      }

      // Get user details from service
      _currentUser =
          await _userService.getUserDetailsByEmail(email: googleUser.email);

      if (_currentUser?.isBlocked ?? false) {
        await signOut();
        return AppStatus.kBlocked;
      }

      // Save to Hive
      await _saveAuthStateToHive(isGoogle: true);
      await HiveService.saveUserToHive(user: _currentUser);

      // Setup user stream
      if (_currentUser != null) {
        _setupUserStream();
      }

      // Store notification token
      await _notificationService.storeDeviceToken(uid: uid);

      return _currentUser != null
          ? AppStatus.kEmailAlreadyExists
          : AppStatus.kSuccess;
    } catch (e) {
      debugPrint("Google Auth Error: $e");
      return AppStatus.kFailed;
    } finally {
      _setLoadingState(false);
    }
  }

  /// Email and Password Registration
  Future<String> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      _setLoadingState(true);

      // Check if username exists
      final bool usernameExists =
          await _userService.isUserNameExists(username: username);
      if (usernameExists) {
        return AppStatus.kUserNameAlreadyExists;
      }

      // Create user
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return AppStatus.kFailed;
      }

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Save auth state
      await HiveService.setFormUserName(username);
      await HiveService.setLoggedIn(true);
      // await HiveService.saveUserToHive(user: user)
      await _notificationService.storeDeviceToken(uid: uid);

      return AppStatus.kSuccess;
    } on FirebaseAuthException catch (e) {
      if (e.code == AppStatus.kEmailAlreadyExists) {
        return AppStatus.kEmailAlreadyExists;
      }
      return e.message ?? "Authentication failed";
    } catch (e) {
      debugPrint("Sign up error: $e");
      return "Sign up failed";
    } finally {
      _setLoadingState(false);
    }
  }

  /// Login with Email and Password
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoadingState(true);

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Get user details
      _currentUser = await _userService.getUserDetailsByEmail(email: email);
      if (_currentUser == null) {
        return AppStatus.kUserNotFound;
      }

      // Check user status
      final Map<String, dynamic> userStatus =
          await _userService.fetchRoleAndCanPostStatus(email: email);
      if (userStatus['status'] == AppStatus.kBlocked) {
        return AppStatus.kBlocked;
      }

      // Update user with latest data
      _currentUser!.role = userStatus['role'] ?? '';
      _currentUser!.canPost = userStatus['canPost'] ?? false;

      // Save to Hive
      await _saveAuthStateToHive();
      await HiveService.saveUserToHive(user: _currentUser);

      // Setup user stream
      _setupUserStream();

      // Store notification token
      await _notificationService.storeDeviceToken(uid: uid);

      return AppStatus.kSuccess;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-credential":
          return AppStatus.kInvalidCredential;
        default:
          return AppStatus.kFailed;
      }
    } catch (e) {
      debugPrint("Sign in error: $e");
      return "Sign in failed";
    } finally {
      _setLoadingState(false);
    }
  }

  /// Reset Password
  Future<String> resetPassword({required String email}) async {
    try {
      final isEmailExists = await _userService.findUserByEmail(email: email);

      if (isEmailExists) {
        await _auth.setLanguageCode("en");
        await _auth.sendPasswordResetEmail(email: email);
        return AppStatus.kSuccess;
      }

      return AppStatus.kEmailNotFound;
    } catch (e) {
      debugPrint("Reset password error: $e");
      return "Password reset failed. Try again.";
    }
  }

  /// Check Email Verification Status
  Future<void> checkEmailVerification() async {
    try {
      await _auth.currentUser?.reload();
      final bool isVerified = _auth.currentUser?.emailVerified ?? false;

      if (isVerified && !isEmailVerified) {
        await HiveService.setEmailVerified(true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Email verification check error: $e");
    }
  }

  /// Start Email Verification Timer
  void startEmailVerificationTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => checkEmailVerification(),
    );
  }

  /// Stop Email Verification Timer
  void stopEmailVerificationTimer() {
    _timer?.cancel();
  }

  /// Resend Email Verification
  Future<void> resendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      debugPrint("Resend email verification error: $e");
    }
  }

  /// Complete Basic Details
  Future<void> completeBasicDetails() async {
    await HiveService.setHasCompletedBasicDetails(true);
    notifyListeners();
  }

  /// Complete Image Setup
  Future<void> completeImageSetup() async {
    await HiveService.setHasCompletedImageSetup(true);
    notifyListeners();
  }

  /// Save authentication state to Hive
  Future<void> _saveAuthStateToHive({bool isGoogle = false}) async {
    await HiveService.setLoggedIn(true);
    await HiveService.setEmailVerified(true);
    await HiveService.setHasCompletedBasicDetails(true);
    await HiveService.setHasCompletedImageSetup(true);
    await HiveService.setIsGoogle(isGoogle);
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      // Cancel streams and timers
      _userStreamSubscription?.cancel();
      _timer?.cancel();

      // Delete notification token
      if (uid.isNotEmpty) {
        await _userService.deleteTokenOnSignOut(uid: uid);
      }

      // Sign out from Firebase
      await _auth.signOut();

      // Sign out from Google if needed
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }

      // Clear Hive data
      await HiveService.clearAllData();

      // Reset state
      _currentUser = null;
      clearControllers();

      debugPrint("User signed out successfully");
    } catch (e) {
      debugPrint("Sign out error: $e");
    } finally {
      notifyListeners();
    }
  }

  /// Clear Controllers
  void clearControllers() {
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  /// Get User Details
  Future<Users?> getUserDetails({required String email}) async {
    try {
      final Users? user =
          await _userService.getUserDetailsByEmail(email: email);
      if (user != null) {
        _currentUser = user;
        await HiveService.saveUserToHive(user: user);
        notifyListeners();
      }
      return user;
    } catch (e) {
      debugPrint("Get user details error: $e");
      return null;
    }
  }

  /// Admin and User Count Stream
  Stream<Map<String, dynamic>> get adminUserCountStream =>
      _userService.userAndAdminCountStream;

  /// Check if user is OAuth authenticated
  Future<bool> get isOAuth async => await _googleSignIn.isSignedIn();

  @override
  void dispose() {
    _timer?.cancel();
    _userStreamSubscription?.cancel();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
