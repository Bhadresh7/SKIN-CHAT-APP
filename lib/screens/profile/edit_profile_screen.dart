import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/helpers/my_navigation.dart';
import 'package:skin_chat_app/helpers/toast_helper.dart';
import 'package:skin_chat_app/providers/auth/basic_user_details_provider.dart';
import 'package:skin_chat_app/widgets/buttons/custom_button.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';
import 'package:skin_chat_app/widgets/inputs/custom_input_field.dart';
import 'package:skin_chat_app/widgets/inputs/date_input_field.dart';

import '../../constants/app_status.dart';
import '../../providers/image_picker_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final aadharController = TextEditingController();
    final mobileNumberController = TextEditingController();
    final dateController = TextEditingController();
    final basicUserDetailsProvider =
        Provider.of<BasicUserDetailsProvider>(context);
    final imagePickerProvider = context.watch<ImagePickerProvider>();

    void clearControllers() {
      usernameController.clear();
      aadharController.clear();
      mobileNumberController.clear();
      dateController.clear();
    }

    return BackgroundScaffold(
      loading: basicUserDetailsProvider.isLoading,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          spacing: 0.03.sh,
          children: [
            GestureDetector(
              onTap: () async {
                String status = await imagePickerProvider.pickImage();
                debugPrint("Image Pick Status: $status");
                setState(() {});
              },
              child: imagePickerProvider.selectedImage == null
                  ? SvgPicture.asset(
                      AppAssets.profile,
                      width: 0.7.sw,
                    )
                  : CircleAvatar(
                      radius: 0.4.sw,
                      backgroundImage: imagePickerProvider.selectedImage != null
                          ? FileImage(imagePickerProvider.selectedImage!)
                          : null, // ✅ Prevent error
                      child: imagePickerProvider.selectedImage == null
                          ? Icon(Icons.person, size: 50) // ✅ Placeholder icon
                          : null,
                    ),
            ),
            CustomInputField(
              controller: usernameController,
              name: "name",
              hintText: "name",
              validators: [
                FormBuilderValidators.required(errorText: "name is required"),
                FormBuilderValidators.username(
                    minLength: 3, errorText: "Enter a valid username"),
              ],
            ),
            CustomInputField(
              controller: aadharController,
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
              controller: mobileNumberController,
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
            DateInputField(
              controller: dateController,
            ),
            // DateInputField(),
            CustomButton(
              text: "update",
              onPressed: () async {
                final result = await basicUserDetailsProvider.updateUserProfile(
                  aadharNumber: aadharController.text.trim(),
                  mobile: mobileNumberController.text.trim(),
                  dob: dateController.text.trim(),
                  name: usernameController.text.trim(),
                );
                if (result == AppStatus.kSuccess) {
                  String aadhar = aadharController.text.trim();
                  String mobile = mobileNumberController.text.trim();
                  String dob = dateController.text.trim();
                  String name = usernameController.text.trim();

                  print("Aadhar Number: $aadhar");
                  print("Mobile Number: $mobile");
                  print("Date of Birth: $dob");
                  print("Username: $name");
                  MyNavigation.back(context);
                  clearControllers();
                  return ToastHelper.showSuccessToast(
                      context: context, message: "Updated Successfully");
                }
                ToastHelper.showErrorToast(context: context, message: result);
              },
            ),
          ],
        ),
      ),
    );
  }
}
