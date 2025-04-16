import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/helpers/date_formater_helper.dart';
import 'package:skin_chat_app/helpers/my_navigation.dart';
import 'package:skin_chat_app/helpers/toast_helper.dart';
import 'package:skin_chat_app/providers/auth/basic_user_details_provider.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';

import '../../constants/app_status.dart';
import '../../providers/image/image_picker_provider.dart';
import '../../widgets/exports.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController usernameController;
  late TextEditingController aadharController;
  late TextEditingController mobileNumberController;
  late TextEditingController dateController;

  late Future<void> _loadUserDataFuture;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    aadharController = TextEditingController();
    mobileNumberController = TextEditingController();
    dateController = TextEditingController();
    _loadUserDataFuture = _loadUserData();
  }

  Future<void> _loadUserData() async {
    final provider = Provider.of<MyAuthProvider>(context, listen: false);
    await provider.getUserDetails(email: provider.email);

    final user = provider.currentUser;
    if (user != null) {
      usernameController.text = user.username;
      aadharController.text = user.aadharNo;
      mobileNumberController.text = user.mobileNumber;
      dateController.text = user.dob;
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    aadharController.dispose();
    mobileNumberController.dispose();
    dateController.dispose();
    // context.read<ImagePickerProvider>().dispose();
    super.dispose();
  }

  void _clearControllers(BuildContext context) {
    usernameController.clear();
    aadharController.clear();
    mobileNumberController.clear();
    dateController.clear();
    context.read<ImagePickerProvider>().clear();
  }

  @override
  Widget build(BuildContext context) {
    final basicUserDetailsProvider = context.watch<BasicUserDetailsProvider>();
    final imagePickerProvider = context.watch<ImagePickerProvider>();
    final provider = Provider.of<MyAuthProvider>(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _clearControllers(context);
      },
      child: FutureBuilder(
        future: _loadUserDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const BackgroundScaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return BackgroundScaffold(
            loading: basicUserDetailsProvider.isLoading,
            appBar: AppBar(),
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: 0.03.sh,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final status = await imagePickerProvider.pickImage();
                        debugPrint("Image Pick Status: $status");
                        setState(() {});
                      },
                      child: imagePickerProvider.selectedImage == null
                          ? SvgPicture.asset(AppAssets.profile, width: 0.7.sw)
                          : CircleAvatar(
                              radius: 0.4.sw,
                              backgroundImage:
                                  FileImage(imagePickerProvider.selectedImage!),
                            ),
                    ),
                    CustomInputField(
                      controller: usernameController,
                      name: "name",
                      hintText: "name",
                      validators: [
                        FormBuilderValidators.required(
                            errorText: "name is required"),
                        FormBuilderValidators.minLength(3,
                            errorText: "Enter a valid username"),
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
                            errorText: "Enter a valid Aadhar number"),
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
                      initialValue: DateFormaterHelper.formatedDate(
                          value: provider.currentUser!.dob),
                    ),
                    CustomButton(
                      text: "Update",
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final result =
                              await basicUserDetailsProvider.updateUserProfile(
                            aadharNumber: aadharController.text.trim(),
                            mobile: mobileNumberController.text.trim(),
                            dob: dateController.text.trim(),
                            name: usernameController.text.trim(),
                          );

                          switch (result) {
                            case AppStatus.kFailed:
                              return ToastHelper.showErrorToast(
                                  context: context,
                                  message: "Aadhar number is not found");
                            case AppStatus.kSuccess:
                              MyNavigation.back(context);
                              ToastHelper.showSuccessToast(
                                  context: context,
                                  message: "Updated Successfully");
                              _clearControllers(context);
                              await provider.getUserDetails(
                                  email:
                                      provider.email); // refresh after update

                              break;
                          }

                          // if (result == AppStatus.kSuccess) {
                          //   MyNavigation.back(context);
                          //   ToastHelper.showSuccessToast(
                          //       context: context,
                          //       message: "Updated Successfully");
                          //   _clearControllers(context);
                          // } else {
                          //   ToastHelper.showErrorToast(
                          //       context: context, message: result);
                          // }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
