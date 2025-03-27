import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/helpers/my_navigation.dart';
import 'package:skin_chat_app/helpers/toast_helper.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';
import 'package:skin_chat_app/providers/image_picker_provider.dart';
import 'package:skin_chat_app/screens/home/home_screen_varient_2.dart';
import 'package:skin_chat_app/widgets/buttons/custom_button.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';

class ImageSetupScreen extends StatefulWidget {
  const ImageSetupScreen({super.key});

  @override
  State<ImageSetupScreen> createState() => _ImageSetupScreenState();
}

class _ImageSetupScreenState extends State<ImageSetupScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MyAuthProvider>(context, listen: false);
    final imagePickerProvider = context.watch<ImagePickerProvider>();

    return BackgroundScaffold(
      body: Column(
        children: [
          if (imagePickerProvider.selectedImage == null)
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  MyNavigation.replace(context, HomeScreenVarient2());
                },
                child: Text(
                  "Skip",
                  style: TextStyle(
                    color: AppStyles.tertiary,
                    fontSize: AppStyles.heading,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                            backgroundImage: imagePickerProvider
                                        .selectedImage !=
                                    null
                                ? FileImage(imagePickerProvider.selectedImage!)
                                : null, // ✅ Prevent error
                            child: imagePickerProvider.selectedImage == null
                                ? Icon(Icons.person,
                                    size: 50) // ✅ Placeholder icon
                                : null,
                          ),
                  ),
                  CustomButton(
                    text: "Next",
                    onPressed: () async {
                      if (imagePickerProvider.selectedImage == null) {
                        ToastHelper.showErrorToast(
                          context: context,
                          message: "Please select a profile image",
                        );
                        return;
                      }

                      String userId = authProvider.uid;
                      String? imageUrl = await imagePickerProvider
                          .uploadImageToFirebase(userId);

                      if (imageUrl == null) {
                        ToastHelper.showErrorToast(
                          context: context,
                          message: "No image is selected",
                        );
                        return;
                      }

                      authProvider.completeImageSetup();
                      MyNavigation.replace(context, HomeScreenVarient2());
                    },
                    width: 90.w,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
