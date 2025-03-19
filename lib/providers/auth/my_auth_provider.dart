import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/entity/users.dart';
import 'package:skin_chat_app/helpers/local_storage.dart';
import 'package:skin_chat_app/services/user_service.dart';

class MyAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _service = UserService();
  User? firebaseUser;

  bool isLoggedIn = false;
  bool _isLoading = false;
  String? _role;

  String get email => _auth.currentUser?.email ?? "no email";

  String get userName => _auth.currentUser?.displayName ?? "no username";

  String get uid => _auth.currentUser?.uid ?? "uid not found";

  String? get role => _role;

  Future<bool> get isOauth async => await _googleSignIn.isSignedIn();

  bool get isLoading => _isLoading;

  void setLoadingState({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  MyAuthProvider() {
    _loadUserDetails();
  }

  ///loading user details
  Future<void> _loadUserDetails() async {
    isLoggedIn = await LocalStorage.getBool("isLoggedIn") ?? false;
    _service.fetchRoleAndSaveLocally(email: email).listen((newRow) {
      _role = newRow;
    });
    notifyListeners();
  }

  /// Google Authentication

  Future<String> googleAuth() async {
    try {
      setLoadingState(value: true);
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AppStatus.kFailed;
      }

      // Obtain auth details from Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return AppStatus.kFailed;
      }

      // Save the user to Firestore

      return AppStatus.kSuccess;
    } catch (e) {
      debugPrint("Google Auth Error: $e");
      return AppStatus.kFailed;
    } finally {
      setLoadingState(value: false);
      notifyListeners();
    }
  }

  /// email and password registration
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      setLoadingState(value: true);
      notifyListeners();
      UserCredential user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (user.user == null) {
        return AppStatus.kFailed;
      }

      ///check if the user already exists in the firestore
      final userExists = await _service.findUserByEmail(email: email);
      if (userExists) {
        return AppStatus.kEmailAlreadyExists;
      }
      //user object
      Users userObj = Users(
        uid: user.user!.uid,
        username: username,
        email: email,
        password: password,
        role: "user",
        canPost: false,
        isAdmin: false,
        isBlocked: false,
        isGoogle: false,
      );

      //saving user object to DB
      await _service.saveUser(user: userObj);

      await LocalStorage.setString("role", "user");
      await LocalStorage.setString("user_email", user.user!.email);
      await LocalStorage.setBool("isLoggedIn", true);
      return AppStatus.kSuccess;
    } catch (e) {
      print(e.toString());
      return AppStatus.kFailed;
    } finally {
      setLoadingState(value: false);
      notifyListeners();
    }
  }

  ///Login Function
  Future<String> loginWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      setLoadingState(value: true);
      notifyListeners();

      bool userExists = await _service.findUserByEmail(email: email);

      ///check if the user does not exists in the firestore
      if (!userExists) {
        return AppStatus.kFailed;
      }
      UserCredential user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (user.user == null) {
        return AppStatus.kFailed;
      }

      _service.fetchRoleAndSaveLocally(email: email).listen((newRow) {
        _role = newRow;
        notifyListeners();
      });
      await LocalStorage.setString("user_email", user.user!.email);
      await LocalStorage.setBool("isLoggedIn", true);
      return AppStatus.kSuccess;
    } catch (e) {
      return e.toString();
    } finally {
      setLoadingState(value: false);
      notifyListeners();
    }
  }

  ///SignOut Function
  Future<void> signOut() async {
    try {
      await _auth.signOut();

      // Check if signed in with Google before disconnecting
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }

      await LocalStorage.clear();
      notifyListeners();
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  Future<String> resetPassword({required String email}) async {
    try {
      await _auth.setLanguageCode("en");
      await _auth.sendPasswordResetEmail(email: email);
      print("FROM PROVIDER =================$email");
      return AppStatus.kSuccess;
    } catch (e) {
      return e.toString();
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
}
