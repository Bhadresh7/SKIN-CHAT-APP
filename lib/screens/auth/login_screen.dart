import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/providers/internet_provider.dart';
import 'package:skin_chat_app/screens/auth/register_screen.dart';
import 'package:skin_chat_app/services/my_navigation.dart';
import 'package:skin_chat_app/widgets/buttons/custom_button.dart';
import 'package:skin_chat_app/widgets/buttons/oauth_button.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';
import 'package:skin_chat_app/widgets/common/or_bar.dart';
import 'package:skin_chat_app/widgets/inputs/custom_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    bool state = false;
    final internetProvider = Provider.of<InternetProvider>(context);
    print(internetProvider.connectionStatus);
    return BackgroundScaffold(
      loading: state,
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
              onPressed: () => {
                setState(() {
                  state = true;
                })
              },
            ),
            ORBar(),
            OAuthButton(
              text: "Continue with google",
              onPressed: () => print("hello there"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Not a member ? "),
                InkWell(
                  onTap: () => MyNavigation.to(context, RegisterScreen()),
                  child: Text(
                    "Register",
                    style: TextStyle(
                        color: AppStyles.links, fontSize: AppStyles.subTitle),
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
