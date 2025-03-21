import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/helpers/my_navigation.dart';
import 'package:skin_chat_app/helpers/toast_helper.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';
import 'package:skin_chat_app/providers/internet_provider.dart';
import 'package:skin_chat_app/screens/auth/forget_password.dart';
import 'package:skin_chat_app/screens/auth/register_screen.dart';
import 'package:skin_chat_app/screens/home/home_screen_varient_2.dart';
import 'package:skin_chat_app/widgets/buttons/custom_button.dart';
import 'package:skin_chat_app/widgets/buttons/oauth_button.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';
import 'package:skin_chat_app/widgets/common/or_bar.dart';
import 'package:skin_chat_app/widgets/inputs/custom_input_field.dart';

import '../profile/basic_details_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    //context.watch => automatically rebuild the ui if there is a change in the context
    ///providers
    final internetProvider = context.watch<InternetProvider>();
    final authProvider = Provider.of<MyAuthProvider>(context);

    ///formKey
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    ///controller
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return BackgroundScaffold(
      loading: authProvider.isLoading,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Form(
          key: formKey,
          child: Column(
            spacing: 0.02.sh,
            children: [
              Lottie.asset(
                AppAssets.login,
                height: 0.4.sh,
              ),
              CustomInputField(
                name: "email",
                hintText: "Email",
                controller: emailController,
                validators: [
                  FormBuilderValidators.email(),
                  FormBuilderValidators.required(
                      errorText: "Email is required"),
                ],
              ),
              CustomInputField(
                isPassword: true,
                name: "password",
                hintText: "Password",
                controller: passwordController,
                validators: [
                  FormBuilderValidators.required(
                      errorText: "Username is required"),
                  FormBuilderValidators.minLength(6,
                      errorText: "Must be at least 6 characters"),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(right: AppStyles.margin),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => MyNavigation.to(context, ForgetPassword()),
                      child: Text("Forget password ?"),
                    ),
                  ],
                ),
              ),
              CustomButton(
                text: "Login",
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    if (emailController.text.trim().isNotEmpty &&
                        passwordController.text.trim().isNotEmpty) {
                      print(emailController.text);
                      print(passwordController.text);
                      final result =
                          await authProvider.loginWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim());
                      if (context.mounted) {
                        if (result == AppStatus.kSuccess) {
                          MyNavigation.replace(context, HomeScreenVarient2());
                          return ToastHelper.showSuccessToast(
                              context: context, message: "Login Success");
                        }
                        return ToastHelper.showErrorToast(
                            context: context, message: "Login Failed");
                      }
                    }
                  }
                },
              ),
              ORBar(),
              OAuthButton(
                  onPressed: () async {
                    final result = await authProvider.googleAuth();
                    if (context.mounted) {
                      if (result == AppStatus.kSuccess) {
                        MyNavigation.replace(context, BasicDetailsScreen());
                        return ToastHelper.showSuccessToast(
                            context: context,
                            message: "Registered successfully");
                      } else if (result == AppStatus.kFailed) {
                        return ToastHelper.showErrorToast(
                            context: context, message: "login canclled");
                      } else if (result == AppStatus.kEmailAlreadyExists) {
                        authProvider.completeBasicDetails();
                        authProvider.completeImageSetup();

                        MyNavigation.replace(context, HomeScreenVarient2());
                        ToastHelper.showSuccessToast(
                            context: context, message: "login successful");
                      }
                    }
                  },
                  text: "Continue with google"),
              InkWell(
                onTap: () => MyNavigation.to(context, RegisterScreen()),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 0.02.sw,
                  children: [
                    Text(
                      "Not a member ?",
                      style: TextStyle(
                        fontSize: AppStyles.subTitle,
                      ),
                    ),
                    Text(
                      "Register",
                      style: TextStyle(
                        fontSize: AppStyles.subTitle,
                        color: AppStyles.links,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
