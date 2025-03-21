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
import 'package:skin_chat_app/screens/home/home_screen_varient_2.dart';
import 'package:skin_chat_app/screens/profile/basic_details_screen.dart';
import 'package:skin_chat_app/widgets/buttons/custom_button.dart';
import 'package:skin_chat_app/widgets/buttons/oauth_button.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';
import 'package:skin_chat_app/widgets/common/or_bar.dart';
import 'package:skin_chat_app/widgets/inputs/custom_input_field.dart';

import 'email_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    /// formKey
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    /// providers
    final authProvider = Provider.of<MyAuthProvider>(context);

    /// controllers
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    ///clearing controllers

    void clearController() {
      usernameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
    }

    return BackgroundScaffold(
      loading: authProvider.isLoading,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Form(
          key: formKey,
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
                controller: usernameController,
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
              CustomInputField(
                isPassword: true,
                name: "confirm password",
                hintText: "Confirm Password",
                controller: confirmPasswordController,
                validators: [
                  FormBuilderValidators.required(
                      errorText: "Username is required"),
                  FormBuilderValidators.minLength(6,
                      errorText: "Must be at least 6 characters"),
                ],
              ),
              CustomButton(
                text: "Signin",
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    if (!(passwordController.text.trim() ==
                        confirmPasswordController.text.trim())) {
                      return ToastHelper.showErrorToast(
                          context: context, message: "Password doesn't match");
                    }
                    final result =
                        await authProvider.signUpWithEmailAndPassword(
                      username: usernameController.text.trim(),
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    );
                    if (context.mounted) {
                      if (result == AppStatus.kSuccess) {
                        authProvider
                            .setPassword(passwordController.text.trim());
                        MyNavigation.replace(
                            context, EmailVerificationScreen());

                        ///clearing controllers
                        clearController();
                      } else if (result == AppStatus.kFailed) {
                        ToastHelper.showErrorToast(
                            context: context,
                            message: "Error while Registering");
                      }
                    }
                  }
                },
              ),

              ///---or--- Divider
              ORBar(),

              ///OAuthButton
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
                            context: context, message: "Failed to register");
                      } else if (result == AppStatus.kEmailAlreadyExists) {
                        authProvider.completeBasicDetails();
                        authProvider.completeImageSetup();
                        MyNavigation.replace(context, HomeScreenVarient2());
                        ToastHelper.showSuccessToast(
                            context: context,
                            message: "registeration successful");
                      }
                    }
                  },
                  text: "Continue with google"),
              InkWell(
                onTap: () => MyNavigation.back(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 0.02.sw,
                  children: [
                    Text(
                      "Already a member ?",
                      style: TextStyle(
                        fontSize: AppStyles.subTitle,
                      ),
                    ),
                    Text(
                      "Login",
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
