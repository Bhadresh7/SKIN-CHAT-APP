import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/widgets/background_scaffold.dart';
import 'package:skin_chat_app/widgets/custom_button.dart';
import 'package:skin_chat_app/widgets/custom_input_field.dart';

class BasicDetailsScreen extends StatelessWidget {
  const BasicDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            spacing: 0.03.sh,
            children: [
              Lottie.asset(AppAssets.login, height: 0.3.sh),
              CustomInputField(name: "name", hintText: "name", validators: [
                FormBuilderValidators.required(errorText: "name is required"),
              ]),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppStyles.margin),
                child: FormBuilderDateTimePicker(
                  name: "DOB",
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  inputType: InputType.date,
                  format: DateFormat("dd/MM/yyyy"),
                  decoration: InputDecoration(
                    hintText: "D.O.B",
                    hintStyle: TextStyle(color: AppStyles.tertiary),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppStyles.borderRadius),
                    ),
                    suffixIcon: Icon(Icons.calendar_today),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.sp, vertical: 14.sp),
                  ),
                  validator: FormBuilderValidators.required(
                    errorText: "Date of Birth is required",
                  ),
                ),
              ),
              CustomButton(text: "submit", onPressed: () {}),
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
