import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_styles.dart';

class OAuthButton extends StatelessWidget {
  final GestureTapCallback onPressed;
  final String text;

  const OAuthButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppStyles.margin),
      child: SizedBox(
        width: double.infinity, // Ensures full width
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppStyles.borderRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppStyles.borderRadius),
              border: Border.all(color: AppStyles.tertiary),
            ),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppAssets.googleIcon,
                  width: 24.w,
                  height: 24.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 12.w),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: AppStyles.subTitle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
