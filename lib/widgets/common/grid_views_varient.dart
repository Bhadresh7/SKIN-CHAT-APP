import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_styles.dart';

class GridViewsVarient extends StatelessWidget {
  const GridViewsVarient({super.key});

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
        return Stack(
          children: [
            Card(
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
                      width: AppStyles.padding,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Bhadresh",
                            style: TextStyle(fontSize: AppStyles.heading),
                          ),
                          Text(
                            "bhadreshpalani19@gmail.com",
                            style: TextStyle(fontSize: AppStyles.bodyText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Positioned Admin Badge at the top-right corner
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                decoration: BoxDecoration(
                  color: AppStyles.primary,
                  borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppAssets.crown,
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
  }
}
