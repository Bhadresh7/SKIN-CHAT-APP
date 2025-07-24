import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/helpers/my_navigation.dart';
import 'package:skin_chat_app/providers/super_admin/super_admin_provider_2.dart';
import 'package:skin_chat_app/screens/profile/user_details_screen.dart';

class UserListView extends StatefulWidget {
  final String filter;

  const UserListView({super.key, required this.filter});

  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initAndLoadUsers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant UserListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      _handleFilterChange();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initAndLoadUsers() {
    // Initialize and load users when the widget is first created
    final provider = Provider.of<SuperAdminProvider2>(context, listen: false);
    provider.initUsers(widget.filter);
  }

  void _handleFilterChange() {
    // Change filter when the filter prop changes
    final provider = Provider.of<SuperAdminProvider2>(context, listen: false);
    provider.changeFilter(widget.filter);
  }

  void _onScroll() {
    // Handle pagination when scrolling to the bottom
    final provider = Provider.of<SuperAdminProvider2>(context, listen: false);
    provider.onScroll(_scrollController);
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
    final provider = Provider.of<SuperAdminProvider2>(context, listen: false);

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
                      provider.togglePostingAccess(userId, !canPost);
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
                    provider.toggleBlockStatus(userId, !isBlocked);
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
                            radius: 50,
                            backgroundImage: CachedNetworkImageProvider(
                              img,
                            ),
                          )
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
                          Text(
                            email,
                            style: TextStyle(
                                fontSize: AppStyles.bodyText,
                                overflow: TextOverflow.ellipsis),
                          ),
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
    return Consumer<SuperAdminProvider2>(
      builder: (context, provider, _) {
        // Show loading indicator when initially loading and users list is empty
        if (provider.isEmpty && provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show empty message when no users are found
        if (provider.isEmpty) {
          return const Center(child: Text("No Users Found"));
        }

        // Build the list of users with pagination
        return RefreshIndicator(
          onRefresh: provider.refreshUsers,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: provider.users.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.users.length) {
                return const Center(child: CircularProgressIndicator());
              }
              print("LIST VIEW ------------------");
              return _buildUserTile(provider.users[index]);
            },
          ),
        );
      },
    );
  }
}
