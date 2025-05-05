import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';
import 'package:skin_chat_app/services/csv_service.dart';
import 'package:skin_chat_app/widgets/buttons/custom_button.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';
import 'package:skin_chat_app/widgets/common/user_list_view.dart';

class ViewUsersScreen extends StatefulWidget {
  const ViewUsersScreen({super.key});

  @override
  State<ViewUsersScreen> createState() => _ViewUsersScreenState();
}

class _ViewUsersScreenState extends State<ViewUsersScreen> {
  late StreamController<double> progressController;
  final CsvService _csvService = CsvService();

  final List<String> chipLabels = ["All", "Employee", "Candidates", "Blocked"];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    progressController = StreamController<double>();
  }

  @override
  void dispose() {
    progressController.close();
    super.dispose();
  }

  void _confirmDownload(String role) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Download"),
        content: Text("Do you want to download the CSV for $role users?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showProgressModal(role);
            },
            child: Text("Confirm", style: TextStyle(color: AppStyles.primary)),
          ),
        ],
      ),
    );
  }

  void _showProgressModal(String role) {
    progressController = StreamController<double>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StreamBuilder<double>(
        stream: progressController.stream,
        initialData: 0,
        builder: (_, snapshot) {
          final progress = snapshot.data ?? 0.0;
          return AlertDialog(
            title: const Text("Downloading CSV"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${(progress * 100).toStringAsFixed(0)}%"),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: progress),
              ],
            ),
          );
        },
      ),
    );

    _csvService
        .fetchUserDetailsAndConvertToCsv(
      role: role,
      progressController: progressController,
    )
        .then((resultMessage) {
      Navigator.pop(context);
      progressController.close();
    });
  }

  void _showDownloadSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Download CSV by Role",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: Icon(Icons.group, color: AppStyles.primary),
                title: const Text("All Users"),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDownload("all");
                },
              ),
              ListTile(
                leading: Icon(Icons.person, color: AppStyles.primary),
                title: const Text("Candidate"),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDownload("user");
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.admin_panel_settings, color: AppStyles.primary),
                title: const Text("Employee"),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDownload("admin");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MyAuthProvider>(context);

    return BackgroundScaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0.1.sh),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            Padding(
              padding: EdgeInsets.only(top: 0.02.sh),
              child: CustomButton(
                height: 0.09.sh,
                width: 0.50.sw,
                text: "Download CSV",
                onPressed: _showDownloadSheet,
                suffixIcon: Icons.file_download_outlined,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<Map<String, int?>>(
            stream: authProvider.adminUserCountStream,
            builder: (_, snapshot) {
              final data = snapshot.data ?? {};
              final employeeCount = data["admin"] ?? 0;
              final candidateCount = data["user"] ?? 0;
              final blockedUserCount = data["blocked"] ?? 0;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text("Employee: $employeeCount  ",
                        style: TextStyle(fontSize: AppStyles.bodyText)),
                    Text("Candidate: $candidateCount  ",
                        style: TextStyle(fontSize: AppStyles.bodyText)),
                    Text("Blocked: $blockedUserCount",
                        style: TextStyle(fontSize: AppStyles.bodyText)),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(chipLabels.length, (index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: ChoiceChip(
                      showCheckmark: false,
                      label: Text(
                        chipLabels[index],
                        style: TextStyle(
                          color: selectedIndex == index
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      selected: selectedIndex == index,
                      selectedColor: AppStyles.primary,
                      onSelected: (_) {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: UserListView(
              filter: chipLabels[selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
