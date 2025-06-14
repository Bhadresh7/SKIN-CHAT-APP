import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/helpers/my_navigation.dart';
import 'package:skin_chat_app/providers/auth/email_verification_provider.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';
import 'package:skin_chat_app/screens/screen_exports.dart';
import 'package:skin_chat_app/widgets/buttons/custom_button.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmailVerificationProvider>(context);
    final authProvider = Provider.of<MyAuthProvider>(context);

    print("FROM THE UI: -----> ${provider.isEmailVerified}");

    if (provider.isEmailVerified || authProvider.isEmailVerified) {
      Future.microtask(() {
        MyNavigation.replace(context, BasicDetailsScreen());
        authProvider.clearControllers();
      });
    }

    return PopScope(
      canPop: false,
      child: BackgroundScaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, size: 100, color: Colors.yellow),
              const SizedBox(height: 20),
              Text(
                "Please verify your email",
                style: TextStyle(
                    fontSize: AppStyles.subTitle, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "A verification email has been sent to ${authProvider.email}",
                style: TextStyle(fontSize: AppStyles.subTitle),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: "Resend Email",
                onPressed: () async {
                  await provider.resendVerificationEmail();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Verification email sent again!")),
                  );
                },
              ),
              SizedBox(height: 0.02.sh),
              CustomButton(
                border: 1.0,
                borderColor: AppStyles.primary,
                fontColor: AppStyles.primary,
                color: AppStyles.smoke,
                text: "Change email",
                onPressed: () async {
                  await provider.cancelEmailVerification();
                  MyNavigation.replace(context, RegisterScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
