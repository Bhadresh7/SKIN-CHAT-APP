import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/helpers/my_navigation.dart';
import 'package:skin_chat_app/screens/profile/basic_details_screen.dart';
import 'package:skin_chat_app/widgets/buttons/custom_button.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';

import '../../providers/auth/email_verification_provider.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmailVerificationProvider(),
      child: Consumer<EmailVerificationProvider>(
        builder: (context, provider, child) {
          if (provider.isEmailVerified) {
            Future.microtask(() {
              MyNavigation.replace(context, BasicDetailsScreen());
            });
          }

          return BackgroundScaffold(
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
                    "A verification email has been sent to your email address.",
                    style: TextStyle(fontSize: AppStyles.subTitle),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: "Resend Email",
                    onPressed: () async {
                      await provider.resendEmail();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Verification email sent again!")),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
