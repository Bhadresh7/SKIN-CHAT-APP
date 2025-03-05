import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/widgets/buttons/custom_button.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';

class ImageSetupScreen extends StatelessWidget {
  const ImageSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      body: Column(
        spacing: 0.15.sh,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                "Skip",
                style: TextStyle(
                  color: AppStyles.tertiary,
                  fontSize: AppStyles.heading,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              spacing: 0.07.sh,
              children: [
                SvgPicture.asset(
                  AppAssets.profile,
                  width: 0.8.sw,
                ),
                CustomButton(
                  text: "Next",
                  onPressed: () {},
                  width: 90.w,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
