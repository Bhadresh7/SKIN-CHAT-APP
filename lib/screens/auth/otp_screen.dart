import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/widgets/background_scaffold.dart';
import 'package:skin_chat_app/widgets/custom_button.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      height: 0.1.sh,
      width: 0.2.sw,
      padding: EdgeInsets.all(AppStyles.padding),
      textStyle: TextStyle(
        fontSize: AppStyles.heading,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
        border: Border.all(color: AppStyles.primary),
      ),
    );

    return BackgroundScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Check Your Email for OTP",
              style: TextStyle(
                fontSize: AppStyles.heading,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 0.1.sh,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppStyles.margin),
              child: Pinput(
                defaultPinTheme: defaultPinTheme,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  "Resend OTP?",
                  style: TextStyle(
                    fontSize: AppStyles.bodyText,
                    color: AppStyles.tertiary,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 0.02.sh,
            ),
            CustomButton(
              text: "Continue",
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
