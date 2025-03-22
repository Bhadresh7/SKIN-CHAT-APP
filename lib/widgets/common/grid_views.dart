import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/widgets/buttons/custom_button.dart';

class GridViews extends StatelessWidget {
  const GridViews({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 0.02.sw,
        crossAxisCount: 1,
        mainAxisSpacing: 0.02.sh,
        childAspectRatio: 16 / 5,
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          color: AppStyles.smoke,
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
                SizedBox(
                  width: 0.05.sw,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Bhadreshpalani",
                            style: TextStyle(
                              fontSize: 16.sp,
                            ),
                          ),
                          Icon(
                            Icons.workspace_premium,
                            color: Colors.amber,
                            size: 20.sp,
                          ),
                        ],
                      ),
                      SizedBox(height: 0.01.sh),
                      Row(
                        children: [
                          CustomButton(
                            color: AppStyles.green,
                            prefixWidget: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            text: "Edit",
                            onPressed: () {},
                            width: 0.25.sw,
                            height: 0.045.sh,
                          ),
                          CustomButton(
                            padding: EdgeInsets.symmetric(horizontal: 0.02.sw),
                            color: AppStyles.danger,
                            prefixWidget: Icon(
                              Icons.block_flipped,
                              color: Colors.white,
                            ),
                            text: "Block",
                            onPressed: () {},
                            width: 0.26.sw,
                            height: 0.045.sh,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
