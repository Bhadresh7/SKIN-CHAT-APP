import 'package:cloud_firestore/cloud_firestore.dart';
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
      QuerySnapshot superAdminSnapshots = await _store
          .collection('super_admins')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (superAdminSnapshots.docs.isNotEmpty) {
        print('user Exist in the super_admin collection');
        return AppStatus.kEmailAlreadyExists;
      }

      // Check if the email already exists
      QuerySnapshot querySnapshot = await _store
          .collection("users")
          .where("email", isEqualTo: user.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print("user exists in the user collection");
        return AppStatus.kEmailAlreadyExists;
      }

      DocumentSnapshot doc =
          await _store.collection("users").doc(user.uid).get();

      if (!doc.exists) {
        await _store.collection("users").doc(user.uid).set(user.toJson());
      } else {
        // Merge to update only missing fields (useful for Google login users)
        await _store.collection("users").doc(user.uid).set({
          "name": user.username,
          "email": user.email,
          "createdAt": DateTime.timestamp()
        }, SetOptions(merge: true));
      }

      print("✅ User saved successfully.");
      return AppStatus.kSuccess;
    } catch (e) {
      print("☠️☠️☠️ Error saving user: ${e.toString()} ☠️☠️☠️");
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

      print("email =====> $mail");
      print("🔥 Updated User Role: $role");
      print("📝 canPost: $canPost");

      await LocalStorage.setString("role", role);
      await LocalStorage.setBool("canPost", canPost);
      await LocalStorage.setString('email', mail);

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

  Stream<Map<String, int>> get userAndAdminCountStream {
    return _store.collection('users').snapshots().map((snapshot) {
      int adminCount =
          snapshot.docs.where((doc) => doc['role'] == 'admin').length;
      int userCount =
          snapshot.docs.where((doc) => doc['role'] == 'user').length;
      return {
        'admin': adminCount,
        'user': userCount,
      };
    });
  }

  ///update user profile
  Future<String> updateUserProfile({
    String? imgUrl,
    String? name,
    required String aadharNumber,
    String? mobile,
    String? dob,
  }) async {
    try {
      var querySnapshot = await _store
          .collection("users")
          .where("aadharNo", isEqualTo: aadharNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var docRef = querySnapshot.docs.first.reference;

        await docRef.set(
          {
            // if (imgUrl != null) "imgUrl": imgUrl,
            if (name != null) "username": name,
            if (mobile != null) "mobileNumber": mobile,
            if (dob != null) "dob": dob,
          },
          SetOptions(merge: true),
        );

        return AppStatus.kSuccess;
      } else {
        return "User with Aadhaar number $aadharNumber not found";
      }
    } catch (e) {
      print(e.toString());
      return AppStatus.kFailed;
    }
  }
}
