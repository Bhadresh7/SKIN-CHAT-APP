import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skin_chat_app/services/hive_service.dart';

class EmailVerificationProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _verificationTimer;

  // Getters that read from Hive
  bool get isEmailVerified => HiveService.isEmailVerified;
  bool get isLoggedIn => HiveService.isLoggedIn;

  EmailVerificationProvider() {
    _initializeEmailVerification();
  }

  /// Initialize email verification process
  void _initializeEmailVerification() {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final bool currentVerificationStatus = currentUser.emailVerified;

    // Update Hive if status changed
    if (currentVerificationStatus != isEmailVerified) {
      HiveService.setEmailVerified(currentVerificationStatus);
      notifyListeners();
    }

    // Start verification check if not verified
    if (!currentVerificationStatus) {
      _sendVerificationEmailIfNeeded();
      _startVerificationTimer();
    }
  }

  /// Send verification email if user exists and email is not verified
  Future<void> _sendVerificationEmailIfNeeded() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null && !currentUser.emailVerified) {
        await currentUser.sendEmailVerification();
        debugPrint("Verification email sent");
      }
    } catch (e) {
      debugPrint("Error sending verification email: $e");
    }
  }

  /// Start timer to periodically check email verification
  void _startVerificationTimer() {
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkEmailVerified(),
    );
  }

  /// Stop the verification timer
  void _stopVerificationTimer() {
    _verificationTimer?.cancel();
  }

  /// Check if email has been verified
  Future<void> _checkEmailVerified() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        _stopVerificationTimer();
        return;
      }

      await currentUser.reload();
      final bool isVerified = _auth.currentUser?.emailVerified ?? false;

      if (isVerified && !isEmailVerified) {
        // Email is now verified, update Hive and stop timer
        await HiveService.setEmailVerified(true);
        await HiveService.setLoggedIn(true);

        _stopVerificationTimer();
        notifyListeners();

        debugPrint("Email verification completed");
      }
    } catch (e) {
      debugPrint("Error checking email verification: $e");
    }
  }

  /// Manually resend verification email
  Future<String> resendVerificationEmail() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return "No user found";
      }

      if (currentUser.emailVerified) {
        return "Email already verified";
      }

      await currentUser.sendEmailVerification();
      return "Verification email sent successfully";
    } catch (e) {
      debugPrint("Error resending verification email: $e");
      return "Failed to send verification email";
    }
  }

  /// Force check email verification status
  Future<void> forceCheckVerification() async {
    await _checkEmailVerified();
  }

  /// Cancel email verification process and delete account
  Future<String> cancelEmailVerification() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return "No user found";
      }

      await currentUser.delete();
      await HiveService.setLoggedIn(false);
      await HiveService.setEmailVerified(false);

      _stopVerificationTimer();
      notifyListeners();

      return "Account deleted successfully";
    } catch (e) {
      debugPrint("Error canceling email verification: $e");
      return "Failed to delete account";
    }
  }

  @override
  void dispose() {
    _stopVerificationTimer();
    super.dispose();
  }
}
