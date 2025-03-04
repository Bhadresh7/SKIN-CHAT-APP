import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skin_chat_app/constants/app_styles.dart';

class ORBar extends StatelessWidget {
  const ORBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 1.h,
          width: 0.35.sw,
          color: AppStyles.tertiary,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text("or"),
        ),
        Container(
          height: 1.h,
          width: 0.35.sw,
          color: AppStyles.tertiary,
        )
      ],
    );
  }
}
