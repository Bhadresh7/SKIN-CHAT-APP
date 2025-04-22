import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skin_chat_app/constants/app_status.dart';

import '../helpers/local_storage.dart';
import '../modal/users.dart';

class UserService {
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  ///saving user to firestore
  // Future<String> saveUser({required Users user}) async {
  //   try {
  //     // Step 1: Check if the user exists in "super_admins"
  //     QuerySnapshot superAdminSnapshot = await _store
  //         .collection("super_admins")
  //         .where("email", isEqualTo: user.email)
  //         .get();
  //
  //     if (superAdminSnapshot.docs.isNotEmpty) {
  //       print("⚠️ User exists in super_admins, no need to create a new one.");
  //       return AppStatus.kEmailAlreadyExists;
  //     }
  //
  //     // Step 2: Check if the user exists in "users"
  //     QuerySnapshot userSnapshot = await _store
  //         .collection("users")
  //         .where("email", isEqualTo: user.email)
  //         .get();
  //
  //     if (userSnapshot.docs.isNotEmpty) {
  //       print("⚠️ User already exists in users, not saving.");
  //       return AppStatus.kEmailAlreadyExists;
  //     }
  //
  //     // Step 3: Create the new user in "users"
  //     await _store.collection("users").doc(user.uid).set({
  //       "username": user.username,
  //       "email": user.email,
  //       "role": "user",
  //       'isAdmin': false,
  //     });
  //
  //     print("✅ User saved successfully.");
  //     return AppStatus.kSuccess;
  //   } catch (e) {
  //     print("☠️ Error saving user: ${e.toString()} ☠️");
  //     return AppStatus.kFailed;
  //   }
  // }

  Future<String> saveUser({required Users user}) async {
    try {
      // Run all queries in parallel for better performance
      final results = await Future.wait([
        _checkDocumentExists('super_admins', 'email', user.email),
        _checkDocumentExists('super_admins', 'aadharNo', user.aadharNo),
        _checkDocumentExists('users', 'email', user.email),
        _checkDocumentExists('users', 'aadharNo', user.aadharNo),
      ]);

      final isEmailInSuperAdmins = results[0];
      final isAadharInSuperAdmins = results[1];
      final isEmailInUsers = results[2];
      final isAadharInUsers = results[3];
      print("===================================");
      print(isEmailInUsers);
      print(isAadharInUsers);
      print("===================================");
      print(isEmailInSuperAdmins);
      print(isEmailInSuperAdmins);
      print("===================================");

      if (isEmailInUsers || isEmailInSuperAdmins) {
        return AppStatus.kEmailAlreadyExists;
      }
      if (isAadharInUsers || isAadharInSuperAdmins) {
        return AppStatus.kaadharNoExists;
      }

      // Save or update the user document
      final userRef = _store.collection("users").doc(user.uid);
      final doc = await userRef.get();

      if (!doc.exists) {
        await userRef.set(user.toJson());
      } else {
        await userRef.set({
          "name": user.username,
          "email": user.email,
          "aadhar": user.aadharNo,
          "createdAt": DateTime.timestamp(),
        }, SetOptions(merge: true));
      }

      print("✅ User saved successfully.");
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
          .collection('super_admins')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return true;
      }

      var querySnapshot = await _store
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("☠️ Error finding user: ${e.toString()}");
      return false; // Return false in case of an error
    }
  }

  /// fetch the user role in real-time
  Stream<Map<String, dynamic>> fetchRoleAndSaveLocally(
      {required String email}) {
    return _store
        .collection("super_admins")
        .where("email", isEqualTo: email)
        .limit(1)
        .snapshots()
        .asyncMap((superAdminSnapshot) async {
      if (superAdminSnapshot.docs.isNotEmpty) {
        return await _processUserData(superAdminSnapshot.docs.first.data());
      }

      // If not found in super_admins, check in the users collection
      return _store
          .collection("users")
          .where("email", isEqualTo: email)
          .limit(1)
          .snapshots()
          .asyncMap((userSnapshot) async {
        if (userSnapshot.docs.isNotEmpty) {
          return await _processUserData(userSnapshot.docs.first.data());
        }
        return _defaultUserData();
      }).first; // Using `first` to get the final result synchronously
    });
  }

// Function to process user data and save it locally
  Future<Map<String, dynamic>> _processUserData(
      Map<String, dynamic> data) async {
    final role = data["role"] ?? "no-role-found";
    final canPost = data["canPost"] ?? false;

    print("🔥 Updated User Role =>>>>>>>>>>: $role");
    print("📝 canPost: $canPost");

    await LocalStorage.setString("role", role);
    await LocalStorage.setBool("canPost", canPost);

    return {
      "role": role,
      "canPost": canPost,
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
      // Check in super_admins collection
      var doc = await _store
          .collection("super_admins")
          .where("email", isEqualTo: email)
          .limit(1)
          .get()
          .then((snapshot) =>
              snapshot.docs.isNotEmpty ? snapshot.docs.first : null);

      doc ??= await _store
          .collection("users")
          .where("email", isEqualTo: email)
          .limit(1)
          .get()
          .then((snapshot) =>
              snapshot.docs.isNotEmpty ? snapshot.docs.first : null);

      if (doc == null) {
        return {
          'status': AppStatus.kUserNotFound,
        };
      }
      print("😍😍😍😍😍😍fetchRoleAndCanPostStatus😍😍😍😍😍😍");
      final mail = doc['email'] ?? "no-email-found";
      final role = doc["role"] ?? "no-role-found";
      final canPost = doc["canPost"] ?? false;
      final isBlocked = doc['isBlocked'] ?? false;

      print("email =====> $mail");
      print("🔥 Updated User Role: $role");
      print("📝 canPost: $canPost");

      await LocalStorage.setString("role", role);
      await LocalStorage.setBool("canPost", canPost);
      await LocalStorage.setString('email', mail);

      if (isBlocked) {
        return {
          'status': AppStatus.kBlocked,
        };
      }

      return {
        'role': role,
        'canPost': canPost,
        'email': mail,
      };
    } catch (e) {
      print("Error fetching role: ${e.toString()}");
      return {
        'status': AppStatus.kUserNotFound,
      };
    }
  }

  Stream<Map<String, int?>> get userAndAdminCountStream {
    return _store.collection('users').snapshots().map((snapshot) {
      int? blockedUserCount = snapshot.docs
          .where((doc) =>
              doc.data().containsKey('isBlocked') && doc['isBlocked'] == true)
          .length;
      print("$blockedUserCount");

      int adminCount =
          snapshot.docs.where((doc) => doc['role'] == 'admin').length;

      int userCount =
          snapshot.docs.where((doc) => doc['role'] == 'user').length;

      return {
        'admin': adminCount,
        'user': userCount,
        'blocked': blockedUserCount,
      };
    });
  }

  ///update user profile
  Future<Users?> updateUserProfile({
    String? imgUrl,
    String? name,
    required String aadharNumber,
    String? mobile,
    String? dob,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      // Check if the user exists
      var querySnapshot = await _store
          .collection("users")
          .where("aadharNo", isEqualTo: aadharNumber)
          .limit(1)
          .get();

      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
      }
      if (querySnapshot.docs.isNotEmpty) {
        var docRef = querySnapshot.docs.first.reference;

        // Prepare fields to update
        Map<String, dynamic> updateData = {};
        if (imgUrl != null) updateData["imgUrl"] = imgUrl;
        if (name != null) updateData["username"] = name;
        if (mobile != null) updateData["mobileNumber"] = mobile;
        if (dob != null) updateData["dob"] = dob;

        // Perform update if needed
        if (updateData.isNotEmpty) {
          await docRef.update(updateData);
        }

        // Re-fetch the updated user document
        var updatedDoc = await docRef.get();
        var data = updatedDoc.data();

        if (data != null) {
          return Users.fromFirestore(data); // Adjust based on your model
        } else {
          return null; // Unexpected: no data found after update
        }
      } else {
        print("User with Aadhaar number $aadharNumber not found");
        return null;
      }
    } catch (e) {
      print("Error updating user profile: $e");
      return null;
    }
  }

  Future<Users?> getUserDetailsByEmail({required String email}) async {
    try {
      final userSnapshot = await _store
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        return Users.fromFirestore(userData);
      }

      final adminSnapshot = await _store
          .collection('super_admins')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (adminSnapshot.docs.isNotEmpty) {
        final adminData = adminSnapshot.docs.first.data();
        return Users.fromFirestore(adminData);
      }

      return null;
    } catch (e) {
      print("Error fetching user by email: $e");
      return null;
    }
  }

  Future<bool> isUserExists({required String username}) async {
    try {
      final result = await Future.wait([
        _store
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get(),
        _store
            .collection('super_admins')
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
      String collection, String field, String value) async {
    final query = await _store
        .collection(collection)
        .where(field, isEqualTo: value)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }
}
