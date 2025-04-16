import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/helpers/my_navigation.dart';
import 'package:skin_chat_app/helpers/toast_helper.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';
import 'package:skin_chat_app/providers/internet/internet_provider.dart';
import 'package:skin_chat_app/widgets/buttons/custom_button.dart';
import 'package:skin_chat_app/widgets/inputs/custom_input_field.dart';

import '../../constants/app_status.dart';
import '../../widgets/common/background_scaffold.dart';

class ForgetPassword extends StatelessWidget {
  ForgetPassword({super.key});

  ///formKey
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ///controller
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ///provider
    final myAuthProvider = Provider.of<MyAuthProvider>(context);
    final internetProvider = context.watch<InternetProvider>();
    return BackgroundScaffold(
      appBar: AppBar(),
      body: Form(
        key: formKey,
        child: Column(
          spacing: 0.03.sh,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomInputField(
              name: "email",
              hintText: "Email",
              controller: emailController,
              validators: [
                FormBuilderValidators.email(),
                FormBuilderValidators.required(errorText: "Email is required"),
              ],
            ),
            CustomButton(
              prefixWidget: Icon(
                Icons.email,
                size: 0.025.sh,
              ),
              text: "Get email",
              onPressed: () async {
                if (internetProvider.connectionStatus ==
                        AppStatus.kDisconnected ||
                    internetProvider.connectionStatus == AppStatus.kSlow) {
                  return ToastHelper.showErrorToast(
                      context: context,
                      message: "Please check your internet connection !!");
                }
                final result = await myAuthProvider.resetPassword(
                  email: emailController.text.trim(),
                );
                print("🔥🔥🔥🔥🔥$result🔥🔥🔥🔥🔥");
                print("🔥🔥🔥🔥🔥${emailController.text}🔥🔥🔥🔥🔥");
                if (context.mounted) {
                  if (result == AppStatus.kSuccess) {
                    ToastHelper.showSuccessToast(
                        context: context,
                        message: "Email has sent to your email");
                    MyNavigation.back(context);
                  } else {
                    ToastHelper.showErrorToast(
                      context: context,
                      message: "Error while send email",
                    );
                  }
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
