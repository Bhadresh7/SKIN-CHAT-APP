import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/helpers/date_formater_helper.dart';
import 'package:skin_chat_app/helpers/toast_helper.dart';
import 'package:skin_chat_app/providers/auth/basic_user_details_provider.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';
import 'package:skin_chat_app/services/hive_service.dart';

import '../../constants/app_status.dart';
import '../../providers/image/image_picker_provider.dart';
import '../../widgets/common_exports.dart';

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
    final data = HiveService.getCurrentUser();
    usernameController.text = data?.username ?? "user";
    aadharController.text = data?.aadharNo ?? "";
    mobileNumberController.text = data?.mobileNumber ?? "";
    dateController.text = data?.dob ?? "";
  }

  @override
  void dispose() {
    usernameController.dispose();
    aadharController.dispose();
    mobileNumberController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final basicUserDetailsProvider = context.watch<BasicUserDetailsProvider>();
    final imagePickerProvider = context.watch<ImagePickerProvider>();
    final provider = Provider.of<MyAuthProvider>(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          imagePickerProvider.clear();
        }
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
            loading: imagePickerProvider.isUploading ||
                basicUserDetailsProvider.isLoading,
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
                      child: imagePickerProvider.selectedImage != null
                          ? CircleAvatar(
                              radius: 0.35.sw,
                              backgroundImage:
                                  FileImage(imagePickerProvider.selectedImage!),
                            )
                          : provider.currentUser?.imageUrl != null
                              ? CircleAvatar(
                                  radius: 0.35.sw,
                                  backgroundImage: NetworkImage(
                                      provider.currentUser!.imageUrl!),
                                )
                              : CircleAvatar(
                                  radius: 0.35.sw,
                                  backgroundImage:
                                      AssetImage(AppAssets.profileImage),
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
                        value: dateController.text,
                      ),
                    ),
                    CustomButton(
                      text: "Update",
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Confirm Update"),
                              content: const Text(
                                  "Do you want to update the profile?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text("Yes"),
                                ),
                              ],
                            ),
                          );

                          if (confirm != true) return;

                          // Upload image only if new image is selected
                          String? imageUrl = provider.currentUser!.imageUrl;
                          if (imagePickerProvider.selectedImage != null) {
                            print(
                                "IMAGE URL -------------------------$imageUrl");
                            imageUrl = await imagePickerProvider
                                .uploadImageToFirebase(provider.uid);
                          }

                          final result =
                              await basicUserDetailsProvider.updateUserProfile(
                            aadharNumber: aadharController.text.trim(),
                            mobile: mobileNumberController.text.trim(),
                            dob: dateController.text.trim(),
                            name: usernameController.text.trim(),
                            imgUrl: imageUrl,
                          );

                          if (result == AppStatus.kFailed) {
                            return ToastHelper.showErrorToast(
                              context: context,
                              message: "Aadhar number is not found",
                            );
                          }

                          if (result == AppStatus.kSuccess) {
                            ToastHelper.showSuccessToast(
                              context: context,
                              message: "Updated Successfully",
                            );
                            await provider.getUserDetails(
                                email: provider.email);
                            imagePickerProvider
                                .clear(); // Optional: Clear the selected image after update
                          }
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
