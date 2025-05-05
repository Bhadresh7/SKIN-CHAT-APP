import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skin_chat_app/helpers/local_storage.dart'; // Assuming you have a helper class for local storage

class EmailVerificationProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isEmailVerified = false;
  bool isLoggedIn = false;
  Timer? _timer;

  // Constructor to initialize the provider
  EmailVerificationProvider() {
    _initializeEmailVerification();
  }

  /// Initialize email verification check and send verification email if needed
  void _initializeEmailVerification() {
    isEmailVerified = _auth.currentUser?.emailVerified ?? false;
    isLoggedIn = _auth.currentUser != null;
    print("Initial email verification status: $isEmailVerified");

    // If the email is not verified, send verification email and start periodic check
    if (!isEmailVerified) {
      _auth.currentUser?.sendEmailVerification();
      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    } else {
      // If already verified, store the status in local storage
      _updateLocalStorage();
    }
  }

  /// Method to check if the email has been verified
  Future<void> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    if (_auth.currentUser?.emailVerified ?? false) {
      isEmailVerified = true;
      isLoggedIn = true;

      // Store status in local storage
      await LocalStorage.setBool("isLoggedIn", true);
      await LocalStorage.setBool("isEmailVerified", true);

      print(
          "🔄 Storing isLoggedIn: ${await LocalStorage.getBool("isLoggedIn")}");
      print(
          "🔄 Storing isEmailVerified: ${await LocalStorage.getBool("isEmailVerified")}");

      _timer?.cancel();
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  /// Re-send email verification
  Future<void> resendEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  /// Update local storage when status changes
  Future<void> _updateLocalStorage() async {
    await LocalStorage.setBool("isLoggedIn", isLoggedIn);
    await LocalStorage.setBool("isEmailVerified", isEmailVerified);
  }

  /// Dispose of the timer when it's no longer needed
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Cancel email check if the user wants to log out or delete account
  Future<void> cancelEmailCheck() async {
    await _auth.currentUser?.delete();
    await _auth.currentUser?.reload();
    await LocalStorage.setBool('isLoggedIn', false); // Mark as logged out
    _timer?.cancel();
    _initializeEmailVerification(); // Re-initialize email verification
  }
}
