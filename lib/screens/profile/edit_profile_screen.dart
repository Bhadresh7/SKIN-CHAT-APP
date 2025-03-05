import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/widgets/buttons/custom_button.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';
import 'package:skin_chat_app/widgets/inputs/custom_input_field.dart';
import 'package:skin_chat_app/widgets/inputs/date_input_field.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(),
      showDrawer: true,
      body: SingleChildScrollView(
        child: Column(
          spacing: 0.03.sh,
          children: [
            SvgPicture.asset(AppAssets.profile),
            CustomInputField(
              name: "name",
              hintText: "name",
              validators: [
                FormBuilderValidators.required(errorText: "name is required"),
                FormBuilderValidators.username(
                    minLength: 3, errorText: "Enter a valid username"),
              ],
            ),
            CustomInputField(
              name: "Aadhar number",
              hintText: "Aadhar number",
              keyboardType: TextInputType.number,
              maxLength: 12,
              validators: [
                FormBuilderValidators.required(
                    errorText: "Aadhar number is required"),
                FormBuilderValidators.match(RegExp(r'^\d{12}$'),
                    errorText: "Enter a valid aadhar")
              ],
            ),
            CustomInputField(
              name: "mobile",
              hintText: "mobile number",
              maxLength: 10,
              keyboardType: TextInputType.number,
              validators: [
                FormBuilderValidators.required(
                    errorText: "Mobile number is required"),
                FormBuilderValidators.match(RegExp(r'^[6789]\d{9}$'),
                    errorText: "Enter a valid mobile number"),
              ],
            ),
            DateInputField(),
            CustomButton(text: "update", onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
