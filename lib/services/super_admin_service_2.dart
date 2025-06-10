import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skin_chat_app/constants/app_db_constants.dart';

class SuperAdminService2 {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _documentLimit = 10;

  Query<Map<String, dynamic>> _getFilteredQuery(String filter) {
    Query<Map<String, dynamic>> query =
        _firestore.collection(AppDbConstants.kUserCollection);
    switch (filter) {
      case "Employer":
        query = query.where('role', isEqualTo: 'admin');
        break;
      case "Candidates":
        query = query.where('role', isEqualTo: 'user');
        break;
      case "Blocked":
        query = query.where('isBlocked', isEqualTo: true);
        break;
    }
    return query.orderBy('username').limit(_documentLimit);
  }

  Future<QuerySnapshot> getUsers(String filter,
      {DocumentSnapshot? lastDocument}) async {
    Query query = _getFilteredQuery(filter);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    return await query.get();
  }

  Future<void> updateUserBlockStatus(String userId, bool isBlocked) async {
    await _firestore
        .collection(AppDbConstants.kUserCollection)
        .doc(userId)
        .update({'isBlocked': isBlocked});
  }

  Future<void> updateUserPostingAccess(String userId, bool canPost) async {
    await _firestore
        .collection(AppDbConstants.kUserCollection)
        .doc(userId)
        .update({'canPost': canPost});
  }

  Future<DocumentSnapshot> getUserDocument(String userId) async {
    return await _firestore
        .collection(AppDbConstants.kUserCollection)
        .doc(userId)
        .get();
  }
}
