import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class SuperAdminProvider extends ChangeNotifier {
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  bool _canPost = false;
  bool get canPost => _canPost;

  ///change user role
  Future<void> enablePosting({required String email}) async {
    try {
      final snapshot = await _store
          .collection("users")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final docId = doc.id;

        await _store.collection("users").doc(docId).update({"canPost": true});

        _canPost = true;
        notifyListeners();

        print("✅ canPost updated successfully for $email");
      } else {
        print("⚠️ No user found with email: $email");
      }
    } catch (e) {
      print("❌ Error updating canPost: $e");
    }
  }

  ///block users
}
