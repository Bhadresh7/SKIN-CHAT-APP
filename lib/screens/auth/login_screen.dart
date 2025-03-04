import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lottie/lottie.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/screens/auth/register_screen.dart';
import 'package:skin_chat_app/services/my_navigation.dart';
import 'package:skin_chat_app/widgets/background_scaffold.dart';
import 'package:skin_chat_app/widgets/custom_button.dart';
import 'package:skin_chat_app/widgets/custom_input_field.dart';
import 'package:skin_chat_app/widgets/oauth_button.dart';
import 'package:skin_chat_app/widgets/or_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          spacing: 0.03.sh,
          children: [
            Lottie.asset(
              AppAssets.login,
              height: 0.4.sh,
            ),
            CustomInputField(
              name: "username",
              hintText: "Username",
              validators: [
                FormBuilderValidators.required(
                    errorText: "Username is required"),
                FormBuilderValidators.minLength(3,
                    errorText: "Must be at least 3 characters"),
              ],
            ),
            CustomInputField(
              name: "password",
              hintText: "Password",
              isPassword: true,
              validators: [
                FormBuilderValidators.required(
                    errorText: "Password is required"),
                FormBuilderValidators.minLength(6,
                    errorText: "Must be at least 6 characters"),
              ],
            ),
            CustomButton(
              text: "Login",
              onPressed: () => {},
            ),
            ORBar(),
            OAuthButton(
              text: "Continue with google",
              onPressed: () => print("Printing......."),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Not a member ? "),
                InkWell(
                    onTap: () => MyNavigation.to(context, RegisterScreen()),
                    child: Text(
                      "Register",
                      style: TextStyle(color: AppStyles.links),
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
