import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skin_chat_app/constants/constants_export.dart'
    show AppStyles, AppText;
import 'package:skin_chat_app/widgets/common_exports.dart'
    show BackgroundScaffold;

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
