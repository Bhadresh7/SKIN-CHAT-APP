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
      return AppStatus.kFailed; // Return error status
    }
  }

  ///find particular user by email
  Future<bool> findUserByEmail({required String email}) async {
    try {
      var querySnapshot = await _store
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1) // Optimizes the query
          .get();

      return querySnapshot.docs.isNotEmpty; // Returns true if email exists
    } catch (e) {
      print("☠️ Error finding user: ${e.toString()}");
      return false; // Return false in case of an error
    }
  }

  ///find the particular userRole by email
  Future<String?> findUserRoleByEmail({required String email}) async {
    try {
      var querySnapshot = await _store
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data();
        String? role = userData['role'] as String?;
        print("✅ User found with role: $role");
        await LocalStorage.setString("role", role);
        return role;
      } else {
        print("⚠️ User not found.");
        return null;
      }
    } catch (e) {
      print("☠️ Error checking user role: $e");
      return null;
    }
  }

  /// fetch the user role in real-time
  Stream<String> fetchRoleAndSaveLocally({required String email}) {
    return _store
        .collection("users")
        .where("email", isEqualTo: email)
        .limit(1)
        .snapshots()
        .map(
      (snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final data = snapshot.docs.first.data();
          final role = data["role"] ?? "no-role-found";
          print("🔥 Updated User Role: $role");
          LocalStorage.setString("role", role);
          return role;
        }
        return "no-role-found";
      },
    );
  }

  Future<String> fetchRole({required String email}) async {
    try {
      var doc = await _store
          .collection("users")
          .where("email", isEqualTo: email)
          .limit(1)
          .get()
          .then((snapshot) =>
              snapshot.docs.isNotEmpty ? snapshot.docs.first : null);

      return doc?["role"] as String? ?? "No email found";
    } catch (e) {
      print("Error fetching role: ${e.toString()}");
      return "Error fetching role";
    }
  }

  ///change the user role in real-time (super-admin only)

// Stream<String> changeUserRole({required String email}) {
//   return ;
// }
}
