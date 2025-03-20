import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerificationProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isEmailVerified = false;
  Timer? _timer;

  EmailVerificationProvider() {
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
      isEmailVerified = true;
      _timer?.cancel();
      notifyListeners();
    }
  }

  Future<void> resendEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
