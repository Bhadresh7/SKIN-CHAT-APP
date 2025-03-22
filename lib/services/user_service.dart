import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/entity/users.dart';

import '../helpers/local_storage.dart';

class UserService {
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  ///saving user to firestore
  Future<String> saveUser({required Users user}) async {
    try {
      // Check if the email already exists
      QuerySnapshot querySnapshot = await _store
          .collection("users")
          .where("email", isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print("Email already exists, not saving the user.");
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
        .collection("users")
        .where("email", isEqualTo: email)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();

        final role = data["role"] ?? "no-role-found";
        final canPost = data["canPost"] ?? false;

        print("🔥 Updated User Role: $role");
        print("📝 canPost: $canPost");

        LocalStorage.setString("role", role);
        LocalStorage.setBool("canPost", canPost);

        return {
          "role": role,
          "canPost": canPost,
        };
      }
      return {
        "role": "no-role-found",
        "canPost": false,
      };
    });
  }

  Future<Map<String, dynamic>> fetchRoleAndCanPostStatus(
      {required String email}) async {
    try {
      var doc = await _store
          .collection("users")
          .where("email", isEqualTo: email)
          .limit(1)
          .get()
          .then((snapshot) =>
              snapshot.docs.isNotEmpty ? snapshot.docs.first : null);

      print("=====================${doc?.data()}=============================");
      final role = doc?["role"] ?? "no-role-found";
      final canPost = doc?["canPost"] ?? false;

      print("🔥 Updated User Role: $role");
      print("📝 canPost: $canPost");

      await LocalStorage.setString("role", role);
      await LocalStorage.setBool("canPost", canPost);

      return {
        'role': role,
        'canPost': canPost,
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
      return {'admin': adminCount, 'user': userCount};
    });
  }
}
