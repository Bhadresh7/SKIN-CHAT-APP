import 'dart:io';

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
    final authProvider = Provider.of<MyAuthProvider>(context);

    return BackgroundScaffold(
      body: Column(
        children: [
          Consumer<ImagePickerProvider>(
            builder: (context, imagePickerProvider, child) {
              return imagePickerProvider.selectedImage == null
                  ? Align(
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
                    )
                  : const SizedBox.shrink();
            },
          ),
          Expanded(
            child: Center(
              child: Consumer<ImagePickerProvider>(
                builder: (context, imagePickerProvider, child) {
                  return Column(
                    spacing: 0.03.sh,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await imagePickerProvider.pickImage();
                        },
                        child: imagePickerProvider.selectedImage == null
                            ? SvgPicture.asset(
                                AppAssets.profile,
                                width: 0.7.sw,
                              )
                            : CircleAvatar(
                                radius: 0.4.sw,
                                backgroundImage: FileImage(
                                  File(imagePickerProvider.selectedImage!.path),
                                ),
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
                          } else {
                            String userId = authProvider.uid;
                            String? imageUrl = await imagePickerProvider
                                .uploadImageToFirebase(userId);

                            if (imageUrl != null) {
                              authProvider.completeImageSetup();
                              MyNavigation.replace(
                                  context, HomeScreenVarient2());
                            } else {
                              ToastHelper.showErrorToast(
                                context: context,
                                message: "Image upload failed. Try again.",
                              );
                            }
                          }
                        },
                        width: 90.w,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
