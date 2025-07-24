import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/models/view_users_model.dart';

import '../../services/super_admin_service.dart';

class SuperAdminProvider with ChangeNotifier {
  final SuperAdminService _service = SuperAdminService();
  bool _isSuperAdmin = false;

  bool get isSuperAdmin => _isSuperAdmin;
  bool _loading = false;

  bool get loading => _loading;
  ViewUsersModel? _viewUsers;

  ViewUsersModel? get viewUsers => _viewUsers;

  void setLoadingState(bool value) {
    _loading = value;
    notifyListeners();
  }

  // In your SuperAdminProvider
  bool _isBlockLoading = false;
  bool _isAdminLoading = false;

  bool get isBlockLoading => _isBlockLoading;

  bool get isAdminLoading => _isAdminLoading;

// Then use these in your respective methods

  Future<void> checkSuperAdminStatus(String email) async {
    try {
      setLoadingState(true);
      _isSuperAdmin = await _service.findAdminByEmail(email: email);
    } catch (e) {
      print(e.toString());
    } finally {
      setLoadingState(false);
      notifyListeners();
    }
  }

  Future<String> makeAsAdmin({required String email}) async {
    try {
      _isAdminLoading = true;
      notifyListeners();
      await _service.togglePosting(email: email);
      await getAllUsers(email: email);
      return AppStatus.kSuccess;
    } catch (e) {
      print(e.toString());
      return AppStatus.kFailed;
    } finally {
      _isAdminLoading = false;
      notifyListeners();
    }
  }

  Future<String> blockUsers({required String uid}) async {
    try {
      _isBlockLoading = true;
      notifyListeners();

      final status = await _service.blockUsers(uid: uid);
      print("🔄 Block toggle result: $status");
      await getAllUsers(email: viewUsers?.email ?? '');

      return status;
    } catch (e) {
      print("❌ Error in provider blockUsers: $e");
      return AppStatus.kFailed;
    } finally {
      _isBlockLoading = false;
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

    if (filter == "Employer") {
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

  Future<ViewUsersModel?> getAllUsers({required String email}) async {
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
