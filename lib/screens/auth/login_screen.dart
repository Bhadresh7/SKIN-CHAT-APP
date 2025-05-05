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
import 'package:skin_chat_app/providers/internet/internet_provider.dart';
import 'package:skin_chat_app/screens/auth/forget_password.dart';
import 'package:skin_chat_app/screens/auth/register_screen.dart';
import 'package:skin_chat_app/screens/home/home_screen_varient_2.dart';
import 'package:skin_chat_app/screens/profile/basic_details_screen.dart';
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
  ///controller
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void getAuthBaseScreen(BuildContext context, String result) {
    switch (result) {
      case AppStatus.kBlocked:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("User Blocked"),
              content: Text("Please contact the Admin for more information"),
              actions: [
                TextButton(
                  onPressed: () => MyNavigation.back(context),
                  child: Text("ok"),
                )
              ],
            );
          },
        );
        break;

      case AppStatus.kInvalidCredential:
        ToastHelper.showErrorToast(
          context: context,
          message: "Invalid credentials",
        );
        break;

      case AppStatus.kSuccess:
        MyNavigation.replace(context, HomeScreenVarient2());
        ToastHelper.showSuccessToast(
          context: context,
          message: "Login Success",
        );
        break;

      case AppStatus.kFailed:
      default:
        ToastHelper.showErrorToast(
          context: context,
          message: "Login failed",
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    //context.watch => automatically rebuild the ui if there is a change in the context
    ///providers
    final internetProvider = context.watch<InternetProvider>();
    final authProvider = Provider.of<MyAuthProvider>(context);

    ///formKey
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
                      errorText: "password is required"),
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
                        password: passwordController.text.trim(),
                      );
                      getAuthBaseScreen(context, result);
                      print("=========================$result");
                    }
                  }
                },
              ),
              ORBar(),
              OAuthButton(
                onPressed: () async {
                  final result = await authProvider.googleAuth();
                  if (!context.mounted) return;

                  print("==========$result========");

                  switch (result) {
                    case AppStatus.kBlocked:
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Blocked"),
                            content: Text(
                                "Please contact the Admin for more information"),
                            actions: [
                              TextButton(
                                onPressed: () => MyNavigation.back(context),
                                child: Text("ok"),
                              )
                            ],
                          );
                        },
                      );

                    case AppStatus.kEmailAlreadyExists:
                      MyNavigation.replace(context, HomeScreenVarient2());
                      ToastHelper.showSuccessToast(
                          context: context, message: "Login Successful");

                      break;

                    case AppStatus.kSuccess:
                      MyNavigation.replace(context, BasicDetailsScreen());
                      break;

                    case AppStatus.kFailed:
                      ToastHelper.showErrorToast(
                          context: context, message: "Login Failed");
                      break;

                    default:
                      print("Google Auth Result: $result");
                      // MyNavigation.replace(context, HomeScreenVarient2());
                      ToastHelper.showErrorToast(
                          context: context, message: result);
                      break;
                  }
                },
                text: 'continue with google',
              ),
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
