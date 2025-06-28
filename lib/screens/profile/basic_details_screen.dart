import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/helpers/my_navigation.dart';
import 'package:skin_chat_app/helpers/password_hashing_helper.dart';
import 'package:skin_chat_app/helpers/toast_helper.dart';
import 'package:skin_chat_app/models/users.dart';
import 'package:skin_chat_app/providers/exports.dart';
import 'package:skin_chat_app/screens/screen_exports.dart';
import 'package:skin_chat_app/widgets/buttons/custom_button.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';
import 'package:skin_chat_app/widgets/inputs/custom_input_field.dart';
import 'package:skin_chat_app/widgets/inputs/date_input_field.dart';

class BasicDetailsScreen extends StatefulWidget {
  const BasicDetailsScreen({super.key});

  @override
  State<BasicDetailsScreen> createState() => _BasicDetailsScreenState();
}

class _BasicDetailsScreenState extends State<BasicDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController userNameController;
  late TextEditingController aadharController;
  late TextEditingController mobileNumberController;
  late TextEditingController dateController;

  @override
  void initState() {
    userNameController = TextEditingController();
    aadharController = TextEditingController();
    mobileNumberController = TextEditingController();
    dateController = TextEditingController();
    super.initState();
    final authProvider = context.read<MyAuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    chatProvider.initMessageStream();

    userNameController.text = authProvider.usernameController.text;
    print("BASIC USER DETAILS ${userNameController.text}");
  }

  @override
  void dispose() {
    userNameController.dispose();
    aadharController.dispose();
    dateController.dispose();
    mobileNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MyAuthProvider>(context);
    final basicDetailsProvider = Provider.of<BasicUserDetailsProvider>(context);
    print("GOOGLE STATUS=====>>>>${context.read<MyAuthProvider>().isGoogle}");

    return PopScope(
      canPop: false,
      child: BackgroundScaffold(
        loading: basicDetailsProvider.isLoading,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                spacing: 0.025.sh,
                children: [
                  Lottie.asset(AppAssets.login, height: 0.3.sh),
                  CustomInputField(
                    controller: userNameController,
                    name: "name",
                    hintText: "name",
                    validators: [
                      FormBuilderValidators.required(
                          errorText: "name is required"),
                    ],
                  ),
                  Container(
                    width: 0.70.sw,
                    alignment: Alignment.center,
                    child: FormBuilderRadioGroup<String>(
                      name: 'role',
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      validator: FormBuilderValidators.required(
                        errorText: "Please select a role",
                      ),
                      options: [
                        FormBuilderFieldOption(
                          value: "admin",
                          child: Text("Employer",
                              style: TextStyle(fontSize: AppStyles.subTitle)),
                        ),
                        FormBuilderFieldOption(
                          value: "user",
                          child: Text("Candidate",
                              style: TextStyle(fontSize: AppStyles.subTitle)),
                        ),
                      ],
                      onChanged: (value) {
                        basicDetailsProvider.selectRole(role: value);
                      },
                    ),
                  ),
                  CustomInputField(
                    controller: aadharController,
                    name: "Aadhar number",
                    maxLength: 12,
                    keyboardType: TextInputType.number,
                    hintText: "Aadhar number",
                    validators: [
                      FormBuilderValidators.required(
                          errorText: "Aadhar number is required"),
                      FormBuilderValidators.match(RegExp(r'^\d{12}$'),
                          errorText: "Enter a valid 12-digit Aadhar number"),
                    ],
                  ),
                  CustomInputField(
                    controller: mobileNumberController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    name: "mobile number",
                    hintText: "mobile number",
                    validators: [
                      FormBuilderValidators.required(
                          errorText: "Mobile number is required"),
                      FormBuilderValidators.match(RegExp(r'^[6-9]\d{9}$'),
                          errorText: "Enter a valid 10-digit mobile number"),
                    ],
                  ),
                  DateInputField(
                    controller: dateController,
                  ),
                  CustomButton(
                    text: "submit",
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          basicDetailsProvider.selectedRole != null) {
                        Users user = Users(
                          dob: dateController.text.trim(),
                          aadharNo: aadharController.text.trim(),
                          mobileNumber: mobileNumberController.text.trim(),
                          uid: authProvider.uid,
                          username: userNameController.text.trim(),
                          email: authProvider.email,
                          role: basicDetailsProvider.selectedRole!,
                          isGoogle: authProvider.isGoogle ? true : false,
                          isBlocked: false,
                          canPost: false,
                          isAdmin: basicDetailsProvider.selectedRole! == "admin"
                              ? true
                              : false,
                          password: PasswordHashingHelper.hashPassword(
                              password: authProvider.passwordController.text),
                        );
                        final result = await basicDetailsProvider
                            .saveUserToDbAndLocally(user);

                        //Handle aadhar exists
                        if (result == AppStatus.kaadharNoExists) {
                          return ToastHelper.showErrorToast(
                            context: context,
                            message: AppStatus.kaadharNoExists,
                          );
                        }

                        // Proceed only if success
                        if (result == AppStatus.kSuccess) {
                          await authProvider.completeBasicDetails();
                          authProvider.clearControllers();
                          if (authProvider.isGoogle) {
                            await authProvider.completeImageSetup();
                            MyNavigation.replace(context, HomeScreenVarient2());
                          } else {
                            MyNavigation.replace(context, ImageSetupScreen());
                          }
                        } else {
                          return ToastHelper.showErrorToast(
                            context: context,
                            message: "Cannot save the user",
                          );
                        }
                      }
                    },
                  ),
                  InkWell(
                    onTap: () =>
                        MyNavigation.to(context, TermsAndConditionsScreen()),
                    child: Text(
                      "Terms & Conditions",
                      style: TextStyle(color: AppStyles.links),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
