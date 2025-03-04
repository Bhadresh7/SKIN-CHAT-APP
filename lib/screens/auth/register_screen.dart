import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lottie/lottie.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/services/my_navigation.dart';
import 'package:skin_chat_app/widgets/background_scaffold.dart';
import 'package:skin_chat_app/widgets/custom_button.dart';
import 'package:skin_chat_app/widgets/custom_input_field.dart';
import 'package:skin_chat_app/widgets/oauth_button.dart';
import 'package:skin_chat_app/widgets/or_bar.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          spacing: 0.025.sh,
          children: [
            Lottie.asset(
              AppAssets.login,
              height: 0.25.sh,
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
              name: "email",
              hintText: "Email",
              validators: [
                FormBuilderValidators.required(
                    errorText: "Username is required"),
                FormBuilderValidators.minLength(3,
                    errorText: "Must be at least 3 characters"),
              ],
            ),
            CustomInputField(
              isPassword: true,
              name: "password",
              hintText: "Password",
              validators: [
                FormBuilderValidators.required(
                    errorText: "Username is required"),
                FormBuilderValidators.minLength(3,
                    errorText: "Must be at least 3 characters"),
              ],
            ),
            CustomInputField(
              isPassword: true,
              name: "confirm password",
              hintText: "Confirm Password",
              validators: [
                FormBuilderValidators.required(
                    errorText: "Username is required"),
                FormBuilderValidators.minLength(3,
                    errorText: "Must be at least 3 characters"),
              ],
            ),
            CustomButton(text: "Signin", onPressed: () {}),
            ORBar(),
            OAuthButton(onPressed: () {}, text: "Continue with google"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have a Account ? "),
                InkWell(
                  onTap: () => MyNavigation.back(context),
                  child: Text(
                    "Login",
                    style: TextStyle(color: AppStyles.links),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
