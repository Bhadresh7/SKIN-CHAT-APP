import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:skin_chat_app/services/super_admin_service_2.dart';

class SuperAdminProvider2 extends ChangeNotifier {
  final SuperAdminService2 _service = SuperAdminService2();

  List<DocumentSnapshot> _users = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  String _currentFilter = "";

  // Getters
  List<DocumentSnapshot> get users => _users;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get isEmpty => _users.isEmpty;

  // Initialize and load users
  Future<void> initUsers(String filter) async {
    _currentFilter = filter;
    await refreshUsers();
  }

  // Refresh user list
  Future<void> refreshUsers() async {
    _users = [];
    _lastDocument = null;
    _hasMore = true;
    notifyListeners();
    await _loadMoreUsers();
  }

  // Load more users for pagination
  Future<void> _loadMoreUsers() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot =
          await _service.getUsers(_currentFilter, lastDocument: _lastDocument);

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _users.addAll(snapshot.docs);
        _hasMore = snapshot.docs.length >= 10; // Using 10 as document limit
      } else {
        _hasMore = false;
      }
    } catch (e) {
      print('Error loading users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if we need to load more data
  void onScroll(ScrollController scrollController) {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMore) {
      _loadMoreUsers();
    }
  }

  // Filter change handling
  void changeFilter(String newFilter) {
    if (_currentFilter != newFilter) {
      _currentFilter = newFilter;
      refreshUsers();
    }
  }

  // User actions
  Future<void> toggleBlockStatus(String userId, bool newBlockStatus) async {
    await _service.updateUserBlockStatus(userId, newBlockStatus);
    await _updateUserLocally(userId, {'isBlocked': newBlockStatus});
  }

  Future<void> togglePostingAccess(String userId, bool newPostAccess) async {
    await _service.updateUserPostingAccess(userId, newPostAccess);
    await _updateUserLocally(userId, {'canPost': newPostAccess});
  }

  // Update user in local state
  Future<void> _updateUserLocally(
      String userId, Map<String, dynamic> updates) async {
    final index = _users.indexWhere((doc) => doc.id == userId);
    if (index != -1) {
      final newSnapshot = await _service.getUserDocument(userId);
      _users[index] = newSnapshot;
      notifyListeners();
    }
  }
}
