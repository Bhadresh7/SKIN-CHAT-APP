import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_status.dart';
import '../../constants/app_styles.dart';

class GridViewsVarient extends StatefulWidget {
  final String filter;
  const GridViewsVarient({super.key, required this.filter});

  @override
  State<GridViewsVarient> createState() => _GridViewsVarientState();
}

class _GridViewsVarientState extends State<GridViewsVarient> {
  Stream<QuerySnapshot> _getUsersStream() {
    Query<Map<String, dynamic>> query = _firestore.collection('users');

    if (widget.filter == "Employee") {
      query = query.where('role', isEqualTo: 'admin');
    } else if (widget.filter == "Candidates") {
      query = query.where('role', isEqualTo: 'user');
    } else if (widget.filter == "Blocked") {
      query = query.where('isBlocked', isEqualTo: true);
    }

    return query.snapshots();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showOptions(
    BuildContext context,
    String userId,
    String userName,
    bool isBlocked,
    bool canPost,
  ) {
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
              if (!isBlocked) // Show access options only if the user is not blocked
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
              if (!isBlocked) Divider(),
              ListTile(
                leading: Icon(
                  isBlocked ? Icons.lock_open : Icons.block,
                  color: isBlocked ? Colors.green : Colors.red,
                ),
                title: Text(isBlocked ? "Unblock" : "Block"),
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

  void _showUserInfoModal(BuildContext context, String userName) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height / 3.5,
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 40, color: AppStyles.danger),
                SizedBox(height: 10),
                Text(
                  "Access Restricted",
                  style: TextStyle(
                    fontSize: AppStyles.heading,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Hello $userName, you need admin access to post.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: AppStyles.subTitle),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No Users Found"));
        }

        var users = snapshot.data!.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        // Separate admins and regular users
        var admins = users.where((user) => user['role'] == 'admin').toList();
        var regularUsers =
            users.where((user) => user['role'] != 'admin').toList();

        // Combine sorted users
        var sortedUsers = [...admins, ...regularUsers];

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 0.02.sw,
            crossAxisCount: 1,
            mainAxisSpacing: 0.02.sh,
            childAspectRatio: 16 / 5,
          ),
          itemCount: sortedUsers.length,
          itemBuilder: (context, index) {
            var userData = sortedUsers[index];
            String userId = snapshot.data!.docs[index].id;
            String name = userData['username'] ?? 'Unknown';
            String email = userData['email'] ?? 'No Email';
            String role = userData['role'] ?? 'user';
            bool isBlocked = userData['isBlocked'] ?? false;
            bool canPost = userData['canPost'] ?? false;
            print("💗💗💗💗💗💗$role💗💗💗💗💗💗");
            print("======>====>===>$canPost<=======<======<======");

            return Stack(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  color: AppStyles.smoke,
                  child: InkWell(
                    onTap: () {
                      if (role == AppStatus.kUser) {
                        return _showUserInfoModal(
                            context, userData['username']);
                      } else {
                        return _showOptions(
                            context, userId, name, isBlocked, canPost);
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.all(12.r),
                      child: Row(
                        children: [
                          // CircleAvatar(
                          //   radius: 30,
                          //   backgroundImage: NetworkImage(img),
                          // ),
                          SizedBox(width: AppStyles.padding),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(fontSize: AppStyles.heading),
                                ),
                                Text(
                                  email,
                                  style:
                                      TextStyle(fontSize: AppStyles.bodyText),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (role == AppStatus.kAdmin && canPost)
                  Positioned(
                    top: 0.02.sh,
                    right: 0.05.sw,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 0.02.sw, horizontal: 0.03.sw),
                      decoration: BoxDecoration(
                        color: AppStyles.primary,
                        borderRadius:
                            BorderRadius.circular(AppStyles.borderRadius),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AppAssets.crown,
                            width: 0.04.sw,
                          ),
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
            );
          },
        );
      },
    );
  }
}
