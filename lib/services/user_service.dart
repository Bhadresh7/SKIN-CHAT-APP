import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/models/users_model.dart';
import 'package:skin_chat_app/services/hive_service.dart';

import '../constants/app_db_constants.dart';

class UserService {
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  ///save user details to db
  Future<String> saveUser({required UsersModel user}) async {
    try {
      final results = await Future.wait([
        _checkDocumentExists(
            AppDbConstants.kSuperAdminCollection, user.email, user.aadharNo),
        _checkDocumentExists(
            AppDbConstants.kUserCollection, user.email, user.aadharNo),
      ]);

      final existsInSuperAdmins = results[0];
      final existsInUsers = results[1];

      if (existsInSuperAdmins || existsInUsers) {
        return AppStatus.kaadharNoExists;
      } else {
        await _store
            .collection(AppDbConstants.kUserCollection)
            .doc(user.uid)
            .set(user.toJson());
      }
      print("✅ User saved successfully.");

      await HiveService.setLoggedIn(true);
      await HiveService.saveUserToHive(user: user);

      return AppStatus.kSuccess;
    } catch (e) {
      print("☠️ Error saving user: ${e.toString()}");
      return AppStatus.kFailed;
    }
  }

  ///find particular user by email
  Future<bool> findUserByEmail({required String email}) async {
    try {
      var query = await _store
          .collection(AppDbConstants.kSuperAdminCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return true;
      }

      var querySnapshot = await _store
          .collection(AppDbConstants.kUserCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("☠️ Error finding user: ${e.toString()}");
      return false;
    }
  }

  /// fetch the user role in real-time
  Stream<Map<String, dynamic>> fetchRoleAndSaveLocally(
      {required String email}) {
    return _store
        .collection(AppDbConstants.kUserCollection)
        .where("email", isEqualTo: email)
        .limit(1)
        .snapshots()
        .asyncMap((userSnapShots) async {
      if (userSnapShots.docs.isNotEmpty) {
        return await _processUserData(userSnapShots.docs.first.data());
      }

      // If not found in super_admins, check in the users collection
      return _store
          .collection(AppDbConstants.kSuperAdminCollection)
          .where("email", isEqualTo: email)
          .limit(1)
          .snapshots()
          .asyncMap(
        (superAdminSnapshots) async {
          if (superAdminSnapshots.docs.isNotEmpty) {
            return await _processUserData(
                superAdminSnapshots.docs.first.data());
          }
          return _defaultUserData();
        },
      ).first; // Using `first` to get the final result synchronously
    });
  }

  // Function to process user data and save it locally
  Future<Map<String, dynamic>> _processUserData(
      Map<String, dynamic> data) async {
    UsersModel usr = UsersModel.fromFirestore(data);

    await HiveService.saveUserToHive(user: usr);

    return {
      "role": usr.role,
      "canPost": usr.canPost,
      "isBlocked": usr.isBlocked,
    };
  }

  // Default user data if no record is found
  Map<String, dynamic> _defaultUserData() {
    return {
      "role": "no-role-found",
      "canPost": false,
    };
  }

  Future<Map<String, dynamic>> fetchRoleAndCanPostStatus({
    required String email,
  }) async {
    try {
      final queries = [
        _store
            .collection(AppDbConstants.kSuperAdminCollection)
            .where("email", isEqualTo: email)
            .limit(1)
            .get(),
        _store
            .collection(AppDbConstants.kUserCollection)
            .where("email", isEqualTo: email)
            .limit(1)
            .get(),
      ];

      final results = await Future.wait(queries);

      DocumentSnapshot<Map<String, dynamic>>? doc;

      for (var snapshot in results) {
        if (snapshot.docs.isNotEmpty) {
          doc = snapshot.docs.first;
          break;
        }
      }

      if (doc == null || doc.data() == null) {
        print("❌ User not found or document is null");
        return {'status': AppStatus.kUserNotFound};
      }

      final data = doc.data()!;
      final mail = data['email'] ?? 'no-email-found';
      final role = data['role'] ?? 'no-role-found';
      final canPost = data['canPost'] ?? false;
      final isBlocked = data['isBlocked'] ?? false;

      print("📥 User Email: $mail");
      print("🔥 User Role: $role");
      print("📝 Can Post: $canPost");
      print("🚫 Is Blocked: $isBlocked");

      UsersModel.fromFirestore(data);

      // await LocalStorage.setString("email", mail);
      // await LocalStorage.setString("role", role);
      // await LocalStorage.setBool("canPost", canPost);

      return {
        'isBlocked': isBlocked,
        'email': mail,
        'role': role,
        'canPost': canPost,
      };
    } catch (e) {
      print("❌ Error in fetchRoleAndCanPostStatus: ${e.toString()}");
      return {'status': AppStatus.kUserNotFound};
    }
  }

  /// Tracks the count of user roles: admin, user, and blocked users.
  Stream<Map<String, int>> get userAndAdminCountStream {
    return _store
        .collection(AppDbConstants.kUserCollection)
        .snapshots()
        .map((snapshot) {
      int adminCount = 0;
      int userCount = 0;
      int blockedUserCount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (data.containsKey('isBlocked') && data['isBlocked'] == true) {
          blockedUserCount++;
        }

        if (data.containsKey('role')) {
          if (data['role'] == 'admin') {
            adminCount++;
          } else if (data['role'] == 'user') {
            userCount++;
          }
        }
      }

      return {
        'admin': adminCount,
        'user': userCount,
        'blocked': blockedUserCount,
      };
    });
  }

  ///update user profile
  Future<UsersModel?> updateUserProfile({
    String? imgUrl,
    String? name,
    required String aadharNumber,
    String? mobile,
    String? dob,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && name != null) {
        await user.updateDisplayName(name);
        await user.reload();
      }

      QuerySnapshot snapshot = await _store
          .collection(AppDbConstants.kUserCollection)
          .where("uid", isEqualTo: user?.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        snapshot = await _store
            .collection(AppDbConstants.kSuperAdminCollection)
            .where("uid", isEqualTo: user?.uid)
            .limit(1)
            .get();

        if (snapshot.docs.isEmpty) {
          print("User with Aadhaar number $aadharNumber not found.");
          return null;
        }
      }

      final docRef = snapshot.docs.first.reference;

      Map<String, dynamic> updateData = {};
      if (imgUrl != null) updateData["imageUrl"] = imgUrl;
      if (name != null) updateData["username"] = name;
      if (mobile != null) updateData["mobileNumber"] = mobile;
      if (dob != null) updateData["dob"] = dob;

      if (updateData.isNotEmpty) {
        await docRef.update(updateData);
      }

      // OPTIONAL: if you really need the updated document, this is read #2
      final data = (await docRef.get()).data() as Map<String, dynamic>;
      return UsersModel.fromFirestore(data);
    } catch (e) {
      print("Error updating user profile: $e");
      return null;
    }
  }

  ///get user details by email for edit profile screen
  Future<UsersModel?> getUserDetailsByEmail({required String email}) async {
    try {
      final userSnapshot = await _store
          .collection(AppDbConstants.kUserCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        return UsersModel.fromFirestore(userData);
      }

      final adminSnapshot = await _store
          .collection(AppDbConstants.kSuperAdminCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (adminSnapshot.docs.isNotEmpty) {
        final adminData = adminSnapshot.docs.first.data();
        return UsersModel.fromFirestore(adminData);
      }

      return null;
    } catch (e) {
      print("Error fetching user by email: $e");
      return null;
    }
  }

  ///check if the user is already exists in the db(Auth purpose)
  Future<bool> isUserNameExists({required String username}) async {
    try {
      final result = await Future.wait([
        _store
            .collection(AppDbConstants.kUserCollection)
            .where('username', isEqualTo: username)
            .limit(1)
            .get(),
        _store
            .collection(AppDbConstants.kSuperAdminCollection)
            .where('username', isEqualTo: username)
            .limit(1)
            .get(),
      ]);
      final userExists = result[0].docs.isNotEmpty;
      final superAdminExists = result[1].docs.isNotEmpty;
      return userExists || superAdminExists;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> _checkDocumentExists(
      String collection, String email, String aadharNo) async {
    final query = await _store
        .collection(collection)
        .where(
          Filter.or(
            Filter('email', isEqualTo: email),
            Filter('aadharNo', isEqualTo: aadharNo),
          ),
        )
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  Future<void> deleteTokenOnSignOut({required String uid}) async {
    try {
      final DatabaseReference tokenRef =
          FirebaseDatabase.instance.ref("tokens/$uid");

      final DataSnapshot snapshot = await tokenRef.get();

      if (!snapshot.exists) {
        print("🚫 No token found for uid: $uid");
        return;
      }

      await tokenRef.remove();
      print("✅ Token deleted successfully for uid: $uid");
    } catch (e) {
      print("🔥 Error deleting token: $e");
    }
  }
}
