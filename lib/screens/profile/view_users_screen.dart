import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/services/csv_service.dart';
import 'package:skin_chat_app/widgets/buttons/custom_button.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';

import '../../widgets/common/grid_views_varient.dart';

class ViewUsersScreen extends StatefulWidget {
  const ViewUsersScreen({super.key});

  @override
  State<ViewUsersScreen> createState() => _ViewUsersScreenState();
}

class _ViewUsersScreenState extends State<ViewUsersScreen> {
  StreamController<double> progressController = StreamController<double>();

  List<String> chipLabels = ["All", "Employee", "Candidates", "Blocked"];
  List<String> roles = ["user", "admin"];
  final CsvService _service = CsvService();
  int selectedIndex = 0;

  void _confirmDownload(String role) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Download"),
          content: Text("Are you sure you want to download the CSV for $role?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showProgressModal(role);
              },
              child:
                  Text("Confirm", style: TextStyle(color: AppStyles.primary)),
            ),
          ],
        );
      },
    );
  }

  void _showProgressModal(String role) {
    progressController = StreamController<double>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StreamBuilder<double>(
          stream: progressController.stream,
          initialData: 0.0,
          builder: (context, snapshot) {
            double progress = snapshot.data ?? 0.0;
            return AlertDialog(
              title: Text("Downloading CSV"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${(progress * 100).toInt()}%"),
                  SizedBox(height: 10),
                  LinearProgressIndicator(value: progress),
                ],
              ),
            );
          },
        );
      },
    );

    _service
        .fetchUserDetailsAndConvertToCsv(
      role: role,
      progressController: progressController,
    )
        .then((_) {
      Navigator.pop(context); // Close the progress dialog when done
      progressController.close();
    });
  }

  void _showDownloadSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Role",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: Icon(Icons.group, color: AppStyles.primary),
                title: Text("All Users"),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDownload("all");
                },
              ),
              ListTile(
                leading: Icon(Icons.person, color: AppStyles.primary),
                title: Text("Candidate"),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDownload("user");
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.admin_panel_settings, color: AppStyles.primary),
                title: Text("Employee"),
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
    return BackgroundScaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0.1.sh),
        child: AppBar(
          actions: [
            Padding(
              padding: EdgeInsets.only(top: 0.02.sh),
              child: CustomButton(
                height: 0.09.sh,
                width: 0.50.sw,
                text: "Download csv",
                onPressed: _showDownloadSheet,
                suffixIcon: Icons.file_download_outlined,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
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
                      onSelected: (bool selected) {
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
            child: GridViewsVarient(filter: chipLabels[selectedIndex]),
            // child: GridWithPagination(filter: chipLabels[selectedIndex]),
          ),
        ],
      ),
    );
  }
}
