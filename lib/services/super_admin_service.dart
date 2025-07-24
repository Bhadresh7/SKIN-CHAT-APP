import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skin_chat_app/constants/app_db_constants.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/models/view_users_model.dart';

class SuperAdminService {
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  /// Check if the given email belongs to a super admin
  Future<bool> findAdminByEmail({required String email}) async {
    try {
      var querySnapshot = await _store
          .collection(AppDbConstants.kSuperAdminCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("❌ Error finding super admin: $e");
      return false;
    }
  }

  /// Enable posting for a user
  Future<void> togglePosting({required String email}) async {
    try {
      final snapshot = await _store
          .collection(AppDbConstants.kUserCollection)
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final docId = doc.id;
        final currentCanPost = doc.get("canPost") as bool? ?? false;

        final newCanPost = !currentCanPost;

        await _store
            .collection(AppDbConstants.kUserCollection)
            .doc(docId)
            .update(
          {
            "canPost": newCanPost,
          },
        );

        print("✅ canPost toggled to $newCanPost for $email");
      } else {
        print("⚠️ No user found with email: $email");
      }
    } catch (e) {
      print("❌ Error toggling canPost: $e");
    }
  }

  ///block users
  Future<String> blockUsers({required String uid}) async {
    try {
      await _store
          .collection(AppDbConstants.kUserCollection)
          .doc(uid)
          .update({'isBlocked': true});

      await _store.collection('tokens').doc(uid).delete();

      // await LocalStorage.clear();

      return AppStatus.kSuccess;
    } catch (e) {
      print(e.toString());
      return AppStatus.kFailed;
    }
  }

  Future<List<DocumentSnapshot>> fetchUsers({
    required String filter,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    Query<Map<String, dynamic>> query =
        _store.collection(AppDbConstants.kUserCollection).limit(limit);

    if (filter == "Employer") {
      query = query.where('role', isEqualTo: 'admin');
    } else if (filter == "Candidates") {
      query = query.where('role', isEqualTo: 'user');
    } else if (filter == "Blocked") {
      query = query.where('isBlocked', isEqualTo: true);
    }

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs;
  }

  Future<ViewUsersModel?> getAllUsers({required String email}) async {
    try {
      final userSnapshot = await _store
          .collection(AppDbConstants.kUserCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        userData.forEach((key, value) {
          print("$key===>$value");
        });
        return ViewUsersModel.fromJson(userData);
      } else {
        return null; // Return null if no user found
      }
    } catch (e) {
      print('Error fetching user: ${e.toString()}');
      return null;
    }
  }
}
