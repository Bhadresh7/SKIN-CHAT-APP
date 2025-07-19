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
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Listen for changes in email verification status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndNavigate();
    });
  }

  void _checkAndNavigate() {
    final provider =
        Provider.of<EmailVerificationProvider>(context, listen: false);
    final authProvider = Provider.of<MyAuthProvider>(context, listen: false);

    if (!_hasNavigated &&
        (provider.isEmailVerified || authProvider.isEmailVerified)) {
      _hasNavigated = true;
      MyNavigation.replace(context, BasicDetailsScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmailVerificationProvider>(
      builder: (context, provider, child) {
        final authProvider = Provider.of<MyAuthProvider>(context);

        print("FROM THE UI: -----> ${provider.isEmailVerified}");

        // Check for navigation when the provider updates
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkAndNavigate();
        });

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
                        fontSize: AppStyles.subTitle,
                        fontWeight: FontWeight.bold),
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
                      final result = await provider.resendVerificationEmail();
                      // Force check verification status after resending
                      await provider.forceCheckVerification();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result)),
                        );
                      }
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
                      if (context.mounted) {
                        MyNavigation.replace(context, RegisterScreen());
                      }
                    },
                  ),
                  SizedBox(height: 0.02.sh),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
