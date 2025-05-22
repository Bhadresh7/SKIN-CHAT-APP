import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skin_chat_app/constants/app_status.dart';

import '../helpers/local_storage.dart';
import '../modal/users.dart';

class UserService {
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  ///save user details to db

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
    // print("FROM ASYNC STREAM -------${data['isBlocked']}");

    final role = data["role"] ?? "no-role-found";
    final canPost = data["canPost"] ?? false;
    final isBlocked = data['isBlocked'] ?? false;

    print("FROM SERVICE ----------$isBlocked");

    print("🔥 Updated User Role =>>>>>>>>>>: $role");
    print("📝 canPost: $canPost");

    await LocalStorage.setString("role", role);
    await LocalStorage.setBool("canPost", canPost);
    await LocalStorage.setBool("isBlocked", isBlocked);

    return {
      "role": role,
      "canPost": canPost,
      "isBlocked": isBlocked,
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
            .collection("super_admins")
            .where("email", isEqualTo: email)
            .limit(1)
            .get(),
        _store
            .collection("users")
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

      await LocalStorage.setString("email", mail);
      await LocalStorage.setString("role", role);
      await LocalStorage.setBool("canPost", canPost);

      if (isBlocked) {
        return {'status': AppStatus.kBlocked};
      }

      return {
        'email': mail,
        'role': role,
        'canPost': canPost,
      };
    } catch (e) {
      print("❌ Error in fetchRoleAndCanPostStatus: ${e.toString()}");
      return {'status': AppStatus.kUserNotFound};
    }
  }

  ///Track the count of the users role (admin,user,blocked users)
  Stream<Map<String, int?>> get userAndAdminCountStream {
    return _store.collection('users').snapshots().map((snapshot) {
      int blockedUserCount = snapshot.docs
          .where((doc) =>
              doc.data().containsKey('isBlocked') && doc['isBlocked'] == true)
          .length;

      int adminCount = snapshot.docs
          .where(
              (doc) => doc.data().containsKey('role') && doc['role'] == 'admin')
          .length;

      int userCount = snapshot.docs
          .where(
              (doc) => doc.data().containsKey('role') && doc['role'] == 'user')
          .length;

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

      if (user != null && name != null) {
        await user.updateDisplayName(name);
        await user.reload();
      }

      // Firestore queries for both collections
      final results = await Future.wait([
        _store
            .collection("users")
            .where("aadharNo", isEqualTo: aadharNumber)
            .limit(1)
            .get(),
        _store
            .collection("super_admins")
            .where("aadharNo", isEqualTo: aadharNumber)
            .limit(1)
            .get(),
      ]);

      // Identify which collection had the user
      final userSnapshot = results[0];
      final superAdminSnapshot = results[1];

      QuerySnapshot foundSnapshot;
      String collectionName;

      if (userSnapshot.docs.isNotEmpty) {
        foundSnapshot = userSnapshot;
        collectionName = "users";
      } else if (superAdminSnapshot.docs.isNotEmpty) {
        foundSnapshot = superAdminSnapshot;
        collectionName = "super_admins";
      } else {
        print(
            "User with Aadhaar number $aadharNumber not found in either collection.");
        return null;
      }

      // Prepare update
      final docRef = foundSnapshot.docs.first.reference;

      Map<String, dynamic> updateData = {};
      if (imgUrl != null) updateData["imageUrl"] = imgUrl;
      if (name != null) updateData["username"] = name;
      if (mobile != null) updateData["mobileNumber"] = mobile;
      if (dob != null) updateData["dob"] = dob;

      // Perform update
      if (updateData.isNotEmpty) {
        await docRef.update(updateData);
        updateData.forEach((key, value) {
          print("[$collectionName] $key => $value");
        });
      }

      // Return updated user object
      final updatedDoc = await docRef.get();
      final data = updatedDoc.data() as Map<String, dynamic>;
      print("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO$data");
      if (data.isNotEmpty) {
        return Users.fromFirestore(data);
      }
      return null;
    } catch (e) {
      print("Error updating user profile: $e");
      return null;
    }
  }

  ///get user details by email for edit profile screen

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

  ///check if the user is already exists in the db(Auth purpose)
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

  Future<void> deleteTokenOnSignOut({required String uid}) async {
    try {
      print(">>>>>>>>>>>>>>>>>>>>>$uid");
      QuerySnapshot snapshot = await _store
          .collection("tokens")
          .where("id", isEqualTo: uid)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print(
            "'''''''''''''''''''''''''''''''RESPONSE IS EMPTY''''''''''''''''''''''''");
        return;
      }

      await _store.collection('tokens').doc(uid).delete();
      print("+++++++++++++++ TOKEN DELETED SUCCESSFULLY +++++++++++++++++++++");
    } catch (e) {
      print("Error deleting token: $e");
    }
  }
}
