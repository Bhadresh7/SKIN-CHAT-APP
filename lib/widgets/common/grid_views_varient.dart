import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_styles.dart';

class GridViewsVarient extends StatefulWidget {
  const GridViewsVarient({super.key});

  @override
  State<GridViewsVarient> createState() => _GridViewsVarientState();
}

class _GridViewsVarientState extends State<GridViewsVarient> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showOptions(BuildContext context, String userId, String userName) {
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
                leading:
                    Icon(Icons.admin_panel_settings, color: AppStyles.primary),
                title: Text("Make as Admin"),
                onTap: () {
                  Navigator.pop(context);
                  _confirmAction(
                    context,
                    "Make as Admin",
                    "Are you sure you want to make $userName an Admin?",
                    () {
                      _firestore.collection('users').doc(userId).update({
                        'role': 'admin',
                      });
                    },
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.block, color: Colors.red),
                title: Text("Block"),
                onTap: () {
                  Navigator.pop(context);
                  _confirmAction(
                    context,
                    "Block User",
                    "Are you sure you want to block $userName?",
                    () {
                      _firestore.collection('users').doc(userId).update({
                        'isBlocked': true,
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
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No Users Found"));
        }

        var users = snapshot.data!.docs;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 0.02.sw,
            crossAxisCount: 1,
            mainAxisSpacing: 0.02.sh,
            childAspectRatio: 16 / 5,
          ),
          itemCount: users.length,
          itemBuilder: (context, index) {
            var user = users[index];
            var userData = user.data() as Map<String, dynamic>;
            String userId = user.id;
            String name = userData['username'] ?? 'Unknown';
            String email = userData['email'] ?? 'No Email';
            String role = userData['role'] ?? 'user';

            return Stack(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  color: AppStyles.smoke,
                  child: InkWell(
                    onTap: () => _showOptions(context, userId, name),
                    child: Padding(
                      padding: EdgeInsets.all(12.r),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 0.15.sw,
                            child: SvgPicture.asset(
                              AppAssets.profile,
                              fit: BoxFit.contain,
                            ),
                          ),
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
                if (role == 'admin')
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: AppStyles.primary,
                        borderRadius:
                            BorderRadius.circular(AppStyles.borderRadius),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(AppAssets.crown),
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
