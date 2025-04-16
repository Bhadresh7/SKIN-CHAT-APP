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
  // Stream<QuerySnapshot> _getUsersStream() {
  //   Query<Map<String, dynamic>> query = _firestore.collection('users');
  //
  //   if (widget.filter == "Employee") {
  //     query = query.where('role', isEqualTo: 'admin');
  //   } else if (widget.filter == "Candidates") {
  //     query = query.where('role', isEqualTo: 'user');
  //   } else if (widget.filter == "Blocked") {
  //     query = query.where('isBlocked', isEqualTo: true);
  //   }
  //   return query.snapshots();
  // }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // void _showOptions(
  //   BuildContext context,
  //   String userId,
  //   String userName,
  //   bool isBlocked,
  //   bool canPost,
  //   String role,
  //   String email,
  // ) {
  //   if (widget.filter == "All") {
  //     return _showUserStatus(
  //         context, userName, role, isBlocked, canPost, email);
  //   }
  //   showModalBottomSheet(
  //     context: context,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
  //     ),
  //     builder: (context) {
  //       return Padding(
  //         padding: EdgeInsets.all(16.r),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             if (!isBlocked)
  //               ListTile(
  //                 leading: Icon(
  //                   canPost ? Icons.cancel : Icons.check_circle,
  //                   color: canPost ? AppStyles.danger : AppStyles.green,
  //                 ),
  //                 title: Text(
  //                   canPost ? "Revoke Posting Access" : "Grant Posting Access",
  //                 ),
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   _confirmAction(
  //                     context,
  //                     canPost ? "Revoke Access" : "Grant Access",
  //                     "Are you sure you want to ${canPost ? 'revoke' : 'grant'} posting access for $userName?",
  //                     () {
  //                       _firestore.collection('users').doc(userId).update({
  //                         'canPost': !canPost,
  //                       });
  //                     },
  //                   );
  //                 },
  //               ),
  //             if (!isBlocked) Divider(),
  //             ListTile(
  //               leading: Icon(
  //                 isBlocked ? Icons.lock_open : Icons.block,
  //                 color: isBlocked ? Colors.green : Colors.red,
  //               ),
  //               title: Text(isBlocked ? "Unblock" : "Block"),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 _confirmAction(
  //                   context,
  //                   isBlocked ? "Unblock User" : "Block User",
  //                   "Are you sure you want to ${isBlocked ? 'unblock' : 'block'} $userName?",
  //                   () {
  //                     _firestore.collection('users').doc(userId).update({
  //                       'isBlocked': !isBlocked,
  //                     });
  //                   },
  //                 );
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _showUserStatus(BuildContext context, String userName, String role,
  //     bool isBlocked, bool canPost, String email) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
  //     ),
  //     builder: (context) {
  //       return Padding(
  //         padding: EdgeInsets.all(16.r),
  //         child: Column(
  //           spacing: 0.02.sh,
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   "User Information",
  //                   style: TextStyle(
  //                     fontSize: AppStyles.heading,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 GestureDetector(
  //                   onTap: () => Navigator.pop(context),
  //                   child: Icon(
  //                     Icons.close,
  //                     size: 24.r,
  //                     color: Colors.black54,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 20.r),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void _confirmAction(BuildContext context, String title, String message,
      VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => MyNavigation.back(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                MyNavigation.back(context);
                onConfirm();
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
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
      builder: (context) {
        return Padding(
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
              Divider(),
              if (!isBlocked && role == "admin") ...[
                ListTile(
                  leading: Icon(
                    canPost ? Icons.cancel : Icons.check_circle,
                    color: canPost ? AppStyles.danger : AppStyles.green,
                  ),
                  title: Text(
                    canPost ? "Revoke Posting Access" : "Grant Posting Access",
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmAction(
                      context,
                      canPost ? "Revoke Access" : "Grant Access",
                      "Are you sure you want to ${canPost ? 'revoke' : 'grant'} posting access for $userName?",
                      () {
                        _firestore.collection('users').doc(userId).update({
                          'canPost': !canPost,
                        });
                      },
                    );
                  },
                ),
                Divider(),
              ],
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
                      _firestore.collection('users').doc(userId).update({
                        'isBlocked': !isBlocked,
                      });
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMore) {
        _getUsers();
      }
    });
  }

  @override
  void didUpdateWidget(covariant UserListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      _users.clear();
      _lastDocument = null;
      _hasMore = true;
      _getUsers();
    }
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

    QuerySnapshot querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;
      _users.addAll(querySnapshot.docs);
    } else {
      _hasMore = false;
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_users.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_users.isEmpty) {
      return const Center(child: Text("No Users Found"));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _users.length +
          ((_hasMore && _users.length >= _documentLimit) ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _users.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final userDoc = _users[index];
        final userData = userDoc.data() as Map<String, dynamic>;

        // same as your rendering logic
        final String userId = userDoc.id;
        final String name = userData['username'] ?? 'Unknown';
        final String email = userData['email'] ?? 'No Email';
        final String role = userData['role'] ?? 'user';
        final bool isBlocked = userData['isBlocked'] ?? false;
        final bool canPost = userData['canPost'] ?? false;
        final String img = userData['imageUrl'] ?? "";

        return Padding(
          padding: EdgeInsets.only(bottom: 0.02.sh),
          child: Stack(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: AppStyles.heading,
                                  )),
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
              if (isBlocked)
                Positioned(
                  top: 15.r,
                  right: 15.r,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 4.r, horizontal: 8.r),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius:
                          BorderRadius.circular(AppStyles.borderRadius),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.block, color: Colors.white, size: 16),
                        SizedBox(width: 4.w),
                        Text("Blocked",
                            style: TextStyle(
                                fontSize: AppStyles.bodyText,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              if (role == AppStatus.kAdmin && canPost && !isBlocked)
                Positioned(
                  top: 15.r,
                  right: 15.r,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 4.r, horizontal: 8.r),
                    decoration: BoxDecoration(
                      color: AppStyles.primary,
                      borderRadius:
                          BorderRadius.circular(AppStyles.borderRadius),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(AppAssets.crown, width: 16.r),
                        SizedBox(width: 4.w),
                        Text(
                          "Admin",
                          style: TextStyle(
                            fontSize: AppStyles.bodyText,
                            color: AppStyles.smoke,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
