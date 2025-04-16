import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/constants/app_text.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            spacing: 0.03.sh,
            children: [
              Text(
                "Terms & conditions",
                style: TextStyle(fontSize: AppStyles.heading),
              ),
              Text(
                AppText.privacyPolicy,
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
