import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/helpers/local_storage.dart';
import 'package:skin_chat_app/helpers/my_navigation.dart';
import 'package:skin_chat_app/providers/auth/basic_user_details_provider.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';
import 'package:skin_chat_app/screens/home/home_screen_varient_2.dart';
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
  String? role = "";
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MyAuthProvider>(context);
    final basicDetailsProvider = Provider.of<BasicUserDetailsProvider>(context);
    return BackgroundScaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            spacing: 0.03.sh,
            children: [
              Lottie.asset(AppAssets.login, height: 0.3.sh),
              CustomInputField(
                name: "name",
                hintText: "name",
                validators: [
                  FormBuilderValidators.required(errorText: "name is required"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio(
                    value: "admin",
                    groupValue: role,
                    onChanged: (value) {
                      setState(
                        () {
                          role = value!;
                          print(role);
                        },
                      );
                    },
                  ),
                  Text(
                    "Employee",
                    style: TextStyle(
                      fontSize: AppStyles.subTitle,
                    ),
                  ),
                  Radio(
                    value: "user",
                    groupValue: role,
                    onChanged: (value) {
                      setState(
                        () {
                          role = value!;
                          print(role);
                        },
                      );
                    },
                  ),
                  Text(
                    "Candidate",
                    style: TextStyle(
                      fontSize: AppStyles.subTitle,
                    ),
                  )
                ],
              ),
              CustomInputField(
                name: "Aadhar number",
                maxLength: 12,
                hintText: "Aadhar number",
                validators: [
                  FormBuilderValidators.required(
                      errorText: "Aadhar number is required"),
                  FormBuilderValidators.match(RegExp(r'^\d{12}$'),
                      errorText: "Enter a valid 12-digit Aadhar number"),
                ],
              ),
              CustomInputField(
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
              DateInputField(),
              CustomButton(
                text: "submit",
                onPressed: () async {
                  await LocalStorage.setBool("isLoggedIn", true);
                  MyNavigation.replace(context, HomeScreenVarient2());
                },
              ),
              InkWell(
                onTap: () {},
                child: Text(
                  "Terms & Conditions",
                  style: TextStyle(color: AppStyles.links),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
