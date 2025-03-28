import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_status.dart';
import '../../constants/app_styles.dart';

class GridWithPagination extends StatefulWidget {
  final String filter;
  const GridWithPagination({super.key, required this.filter});

  @override
  State<GridWithPagination> createState() => _GridWithPaginationState();
}

class _GridWithPaginationState extends State<GridWithPagination> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<DocumentSnapshot>> _usersFuture;

  @override
  void didUpdateWidget(covariant GridWithPagination oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _usersFuture = _getDocuments();
    }
  }

  @override
  void initState() {
    super.initState();
    _usersFuture = _getDocuments();
  }

  Future<List<DocumentSnapshot>> _getDocuments() async {
    Query<Map<String, dynamic>> query = _firestore.collection('users');

    if (widget.filter == "Employee") {
      query = query
          .where('role', isEqualTo: 'admin')
          .where('isBlocked', isEqualTo: false);
    } else if (widget.filter == "Candidates") {
      query = query
          .where('role', isEqualTo: 'user')
          .where('isBlocked', isEqualTo: false);
    } else if (widget.filter == "Blocked") {
      query = query.where('isBlocked', isEqualTo: true);
    }

    QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    return snapshot.docs;
  }

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
                setState(() {
                  _usersFuture = _getDocuments();
                });
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
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No users found"));
        }

        List<DocumentSnapshot> users = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: users.length,
          itemBuilder: (context, index) {
            var userData = users[index].data() as Map<String, dynamic>;
            bool isAdmin = userData['role'] == 'admin';
            bool canPost = userData['canPost'];
            String uid = userData['uid'];
            String username = userData['username'];
            bool isBlocked = userData['isBlocked'];
            String role = userData['role'];

            return Stack(
              children: [
                InkWell(
                  onTap: () {
                    role == AppStatus.kAdmin
                        ? _showOptions(
                            context, uid, username, isBlocked, canPost)
                        : _showUserInfoModal(context, username);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    color: isBlocked
                        ? Colors.red.shade200
                        : Colors.white, // Change color
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12.0),
                      leading: CircleAvatar(
                        backgroundColor:
                            isBlocked ? Colors.red : Colors.blueAccent,
                        child: Icon(
                          isBlocked ? Icons.block : Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        userData['username'] ?? 'No Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isBlocked ? Colors.black54 : Colors.black,
                          decoration:
                              isBlocked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text(
                        userData['email'] ?? 'No Email',
                        style: TextStyle(
                          color: isBlocked ? Colors.black54 : Colors.black,
                        ),
                      ),
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
