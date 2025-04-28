import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/helpers/local_storage.dart';
import 'package:skin_chat_app/modal/view_users.dart';

import '../../services/super_admin_service.dart';

class SuperAdminProvider with ChangeNotifier {
  final SuperAdminService _service = SuperAdminService();
  bool _isSuperAdmin = false;
  bool get isSuperAdmin => _isSuperAdmin;
  bool _loading = false;
  bool get loading => _loading;
  ViewUsers? _viewUsers;

  ViewUsers? get viewUsers => _viewUsers;

  void setLoadingState(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> checkSuperAdminStatus(String email) async {
    try {
      setLoadingState(true);
      _isSuperAdmin = await _service.findSuperAdminByEmail(email: email);
      await LocalStorage.setBool('isLoggedIn', true);
      await LocalStorage.setBool('isEmailVerified', true);
      await LocalStorage.setString('role', 'super_admin');
      await LocalStorage.setBool("canPost", true);
    } catch (e) {
      print(e.toString());
    } finally {
      setLoadingState(false);
      notifyListeners();
    }
  }

  Future<String> makeAsAdmin({required String email}) async {
    try {
      setLoadingState(true);
      await _service.togglePosting(email: email);
      return AppStatus.kSuccess;
    } catch (e) {
      print(e.toString());
      return AppStatus.kFailed;
    } finally {
      setLoadingState(false);
      notifyListeners();
    }
  }



  Future<String> blockUsers({required String uid}) async {
    try {
      setLoadingState(true);
      notifyListeners();


      final blockedUsers= await _service.blockUsers(uid: uid);
      print("=========$blockedUsers========");
      return blockedUsers;
    } catch (e) {
      print(e.toString());
      return e.toString();
    } finally {
      setLoadingState(false);
      notifyListeners();
    }
  }

  final FirebaseFirestore _store = FirebaseFirestore.instance;
  final List<DocumentSnapshot> _users = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  List<DocumentSnapshot> get users => _users;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> fetchUsers(String filter, {bool reset = false}) async {
    if (_isLoading) return;

    if (reset) {
      _users.clear();
      _lastDocument = null;
      _hasMore = true;
      notifyListeners();
    }

    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();

    final newUsers = await _fetchUsersFromFirestore(filter);

    if (newUsers.isNotEmpty) {
      _lastDocument = newUsers.last;
      _users.addAll(newUsers);
      if (newUsers.length < 10) {
        _hasMore = false;
      }
    } else {
      _hasMore = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<DocumentSnapshot>> _fetchUsersFromFirestore(String filter) async {
    Query<Map<String, dynamic>> query = _store.collection('users').limit(10);

    if (filter == "Employee") {
      query = query.where('role', isEqualTo: 'admin');
    } else if (filter == "Candidates") {
      query = query.where('role', isEqualTo: 'user');
    } else if (filter == "Blocked") {
      query = query.where('isBlocked', isEqualTo: true);
    }

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();
    return snapshot.docs;
  }

  Future<ViewUsers?> getAllUsers({required String email}) async {
    try {
      final user = await _service.getAllUsers(email: email);
      if (user != null) {
        _viewUsers = user;
        notifyListeners();
      } else {
        print(AppStatus.kUserNotFound);
      }
      return user;
    } catch (e) {
      print('Error fetching user: ${e.toString()}');
      return null;
    }
  }
}
