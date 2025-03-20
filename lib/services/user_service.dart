import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skin_chat_app/entity/users.dart';

import '../helpers/local_storage.dart';

class UserService {
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  ///saving user to firestore
  Future<void> saveUser({required Users user}) async {
    try {
      DocumentSnapshot doc =
          await _store.collection("users").doc(user.uid).get();

      if (!doc.exists) {
        // Create a new user document if it doesn't exist
        await _store.collection("users").doc(user.uid).set(user.toJson());
      } else {
        // Merge to update only missing fields (useful for Google login users)
        await _store.collection("users").doc(user.uid).set({
          "name": user.username,
          "email": user.email,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("☠️☠️☠️ Error saving user: ${e.toString()} ☠️☠️☠️");
    }
  }

  ///find the particular user by email

  Future<bool> findUserByEmail({required String email}) async {
    try {
      var querySnapshot = await _store
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      print(
          "😶‍🌫️😶‍🌫️😶‍🌫️😶‍🌫️😶‍🌫️${querySnapshot.docs.isNotEmpty}😶‍🌫️😶‍🌫️😶‍🌫️😶‍🌫️😶‍🌫️");
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking user existence: $e");
      return false;
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
