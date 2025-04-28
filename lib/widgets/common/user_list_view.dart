import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/helpers/my_navigation.dart';
import 'package:skin_chat_app/screens/profile/user_details_screen.dart';

class UserListView extends StatefulWidget {
  final String filter;

  const UserListView({super.key, required this.filter});

  @override
  State<UserListView> createState() => _GridViewsVarientState();
}

class _GridViewsVarientState extends State<UserListView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final ScrollController _scrollController = ScrollController();
  final List<DocumentSnapshot> _users = [];
  bool _isLoading = false;
  bool _hasMore = true;
  final int _documentLimit = 10;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _getUsers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant UserListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      _refreshUserList();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMore) {
      _getUsers();
    }
  }

  void _refreshUserList() {
    setState(() {
      _users.clear();
      _lastDocument = null;
      _hasMore = true;
    });
    _getUsers();
  }

  Query<Map<String, dynamic>> _getQuery() {
    Query<Map<String, dynamic>> query = _firestore.collection('users');
    switch (widget.filter) {
      case "Employee":
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

  Future<void> _getUsers() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    Query query = _getQuery();
    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
      _users.addAll(snapshot.docs);
    } else {
      _hasMore = false;
    }

    setState(() => _isLoading = false);
  }

  Future<void> _updateUserLocally(
      String userId, Map<String, dynamic> updates) async {
    final index = _users.indexWhere((doc) => doc.id == userId);
    if (index != -1) {
      final userData = Map<String, dynamic>.from(
          _users[index].data() as Map<String, dynamic>);
      updates.forEach((key, value) => userData[key] = value);

      final newSnapshot =
          await _users[index].reference.get(); // Fetch updated document
      _users[index] = newSnapshot;

      setState(() {});
    }
  }

  void _confirmAction(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text("Yes"),
          ),
        ],
      ),
    );
  }

  void _showOptionsSheet({
    required BuildContext context,
    required String userId,
    required String userName,
    required bool isBlocked,
    required bool canPost,
    required String role,
    required String email,
  }) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person, color: AppStyles.primary),
              title: Text("View User Details"),
              onTap: () {
                Navigator.pop(context);
                MyNavigation.to(context, UserDetailsScreen(email: email));
              },
            ),
            if (!isBlocked && role == "admin") ...[
              Divider(),
              ListTile(
                leading: Icon(
                  canPost ? Icons.cancel : Icons.check_circle,
                  color: canPost ? AppStyles.danger : AppStyles.green,
                ),
                title: Text(
                    canPost ? "Revoke Posting Access" : "Grant Posting Access"),
                onTap: () {
                  Navigator.pop(context);
                  _confirmAction(
                    context,
                    canPost ? "Revoke Access" : "Grant Access",
                    "Are you sure you want to ${canPost ? 'revoke' : 'grant'} posting access for $userName?",
                    () {
                      _firestore
                          .collection('users')
                          .doc(userId)
                          .update({'canPost': !canPost});
                      _updateUserLocally(userId, {'canPost': !canPost});
                    },
                  );
                },
              ),
            ],
            Divider(),
            ListTile(
              leading: Icon(
                isBlocked ? Icons.lock_open : Icons.block,
                color: isBlocked ? Colors.green : Colors.red,
              ),
              title: Text(isBlocked ? "Unblock User" : "Block User"),
              onTap: () {
                Navigator.pop(context);
                _confirmAction(
                  context,
                  isBlocked ? "Unblock User" : "Block User",
                  "Are you sure you want to ${isBlocked ? 'unblock' : 'block'} $userName?",
                  () {
                    _firestore
                        .collection('users')
                        .doc(userId)
                        .update({'isBlocked': !isBlocked});
                    _updateUserLocally(userId, {'isBlocked': !isBlocked});
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTile(DocumentSnapshot userDoc) {
    final user = userDoc.data() as Map<String, dynamic>;

    final userId = userDoc.id;
    final name = user['username'] ?? 'Unknown';
    final email = user['email'] ?? 'No Email';
    final role = user['role'] ?? 'user';
    final isBlocked = user['isBlocked'] ?? false;
    final canPost = user['canPost'] ?? false;
    final img = user['imageUrl'] ?? "";

    return Padding(
      padding: EdgeInsets.only(bottom: 0.02.sh),
      child: Stack(
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            color: AppStyles.smoke,
            child: InkWell(
              onTap: () => _showOptionsSheet(
                context: context,
                userId: userId,
                userName: name,
                isBlocked: isBlocked,
                canPost: canPost,
                role: role,
                email: email,
              ),
              child: Padding(
                padding: EdgeInsets.all(12.r),
                child: Row(
                  children: [
                    img.isNotEmpty
                        ? CircleAvatar(
                            radius: 50, backgroundImage: NetworkImage(img))
                        : CircleAvatar(
                            radius: 50,
                            child: SvgPicture.asset(AppAssets.profile)),
                    SizedBox(width: AppStyles.padding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(name,
                              style: TextStyle(
                                  fontSize: AppStyles.heading,
                                  overflow: TextOverflow.ellipsis)),
                          Text(email,
                              style: TextStyle(
                                  fontSize: AppStyles.bodyText,
                                  overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isBlocked) _buildBadge("Blocked", Colors.red, Icons.block),
          if (role == AppStatus.kAdmin && canPost && !isBlocked)
            _buildBadge("Admin", AppStyles.primary, null,
                iconAsset: AppAssets.crown),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color, IconData? icon,
      {String? iconAsset}) {
    return Positioned(
      top: 15.r,
      right: 15.r,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.r, horizontal: 8.r),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppStyles.borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconAsset != null
                ? Image.asset(iconAsset, width: 16.r)
                : Icon(icon, size: 16, color: Colors.white),
            SizedBox(width: 4.w),
            Text(label,
                style: TextStyle(
                    fontSize: AppStyles.bodyText, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_users.isEmpty && _isLoading)
      return const Center(child: CircularProgressIndicator());
    if (_users.isEmpty) return const Center(child: Text("No Users Found"));

    return ListView.builder(
      controller: _scrollController,
      itemCount: _users.length +
          ((_hasMore && _users.length >= _documentLimit) ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _users.length)
          return const Center(child: CircularProgressIndicator());
        return _buildUserTile(_users[index]);
      },
    );
  }
}
