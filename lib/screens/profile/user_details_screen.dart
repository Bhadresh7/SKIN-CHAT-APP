import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/helpers/toast_helper.dart';
import 'package:skin_chat_app/providers/super_admin/super_admin_provider.dart';
import 'package:skin_chat_app/widgets/buttons/custom_button.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key, required this.email});

  final String email;

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late Future<void> _loadUsers;

  @override
  void initState() {
    super.initState();
    _loadUsers = _loadUserData();
  }

  Future<void> _loadUserData() async {
    final adminProvider =
        Provider.of<SuperAdminProvider>(context, listen: false);
    await adminProvider.getAllUsers(email: widget.email);
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<SuperAdminProvider>(context);

    return FutureBuilder<void>(
      future: _loadUsers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return BackgroundScaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return BackgroundScaffold(
            body: Center(child: Text('Error loading user data')),
          );
        }

        final user = adminProvider.viewUsers;

        return BackgroundScaffold(
          appBar: AppBar(),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
            child: Column(
              spacing: 0.03.sh,
              children: [
                Center(
                  child: (user?.img == null || user!.img!.isEmpty)
                      ? SvgPicture.asset(
                          AppAssets.profile,
                          height: 0.2.sh,
                          width: 0.2.sw,
                        )
                      : ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: user.img ?? "",
                            height: 0.20.sh,
                            width: 0.20.sh,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                SvgPicture.asset(
                              AppAssets.profile,
                              height: 0.2.sh,
                              width: 0.2.sw,
                            ),
                          ),
                        ),
                ),
                Text(
                  'User Details',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 6,
                  margin: EdgeInsets.symmetric(vertical: 10.h),
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Name', user?.name),
                        _buildDetailRow('Email', user?.email),
                        _buildDetailRow('Mobile No', user?.mobileNumber),
                        _buildDetailRow('DOB', user?.dob)
                      ],
                    ),
                  ),
                ),
                if (user?.canPost == true)
                  CustomButton(
                    isLoading: adminProvider.isAdminLoading,
                    text: "Revoke Permission",
                    onPressed: () async {
                      final status =
                          await adminProvider.makeAsAdmin(email: widget.email);
                      switch (status) {
                        case AppStatus.kSuccess:
                          return ToastHelper.showSuccessToast(
                              context: context, message: "Permission revoked");
                        case AppStatus.kFailed:
                          return ToastHelper.showErrorToast(
                              context: context, message: "Failed to revoke");
                        default:
                          return ToastHelper.showErrorToast(
                              context: context, message: status);
                      }
                    },
                    color: Colors.orange,
                    prefixWidget: Icon(Icons.remove_circle_outline),
                  )
                else if (user?.role == AppStatus.kAdmin &&
                    !(user?.canPost ?? true))
                  CustomButton(
                    isLoading: adminProvider.isAdminLoading,
                    text: "Make as Admin",
                    onPressed: () async {
                      final status =
                          await adminProvider.makeAsAdmin(email: widget.email);
                      switch (status) {
                        case AppStatus.kSuccess:
                          return ToastHelper.showSuccessToast(
                              context: context,
                              message: "User is now an Admin");
                        case AppStatus.kFailed:
                          return ToastHelper.showErrorToast(
                              context: context, message: "Failed");
                        default:
                          return ToastHelper.showErrorToast(
                              context: context, message: status);
                      }
                    },
                    color: AppStyles.green,
                    prefixWidget: Icon(Icons.person),
                  ),
                CustomButton(
                  isLoading: adminProvider.isBlockLoading,
                  text: user?.isBlocked == true ? "Unblock User" : "Block User",
                  onPressed: () async {
                    final result =
                        await adminProvider.blockUsers(uid: user!.uid);

                    switch (result) {
                      case AppStatus.kSuccess:
                        return ToastHelper.showSuccessToast(
                          context: context,
                          message: user.isBlocked
                              ? "User is Unblocked"
                              : "User is Blocked",
                        );
                      case AppStatus.kFailed:
                        return ToastHelper.showErrorToast(
                          context: context,
                          message: "Failed to update block status",
                        );
                      default:
                        return ToastHelper.showErrorToast(
                          context: context,
                          message: result,
                        );
                    }
                  },
                  color: user?.isBlocked == true
                      ? Colors.green[900]
                      : AppStyles.danger,
                  prefixWidget: Icon(
                    user?.isBlocked == true
                        ? Icons.lock_open
                        : Icons.block_flipped,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppStyles.bodyText,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                fontSize: AppStyles.bodyText,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
