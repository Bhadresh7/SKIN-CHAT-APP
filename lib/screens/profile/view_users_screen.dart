import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/widgets/buttons/custom_button.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';
import 'package:skin_chat_app/widgets/common/grid_views_varient.dart';

class ViewUsersScreen extends StatefulWidget {
  const ViewUsersScreen({super.key});

  @override
  State<ViewUsersScreen> createState() => _ViewUsersScreenState();
}

class _ViewUsersScreenState extends State<ViewUsersScreen> {
  List<String> chipLabels = ["All", "Admins", "Blocked"];
  int selectedIndex = 0;

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
                onPressed: () {},
                suffixIcon: Icons.file_download_outlined,
              ),
            ),
          ],
        ),
      ),
      showDrawer: true,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
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
          Expanded(child: GridViewsVarient()),
        ],
      ),
    );
  }
}
