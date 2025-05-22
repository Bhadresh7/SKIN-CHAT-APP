import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skin_chat_app/constants/app_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Widget? prefixWidget;
  final IconData? suffixIcon;
  final bool isLoading;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? loadingColor;
  final double? border;
  final Color? fontColor;
  final Color? borderColor;
  final bool enabled;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.prefixWidget,
    this.suffixIcon,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
    this.loadingColor,
    this.border,
    this.fontColor,
    this.borderColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: AppStyles.margin),
      child: ConstrainedBox(
        constraints: width != null
            ? BoxConstraints(maxWidth: width!)
            : const BoxConstraints(),
        child: SizedBox(
          width: width ?? double.infinity,
          height: height ?? 0.06.sh,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color ?? AppStyles.primary,
              foregroundColor: fontColor ?? Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                side: border != null
                    ? BorderSide(
                        color: borderColor ?? Colors.white,
                        width: border!,
                      )
                    : BorderSide.none,
              ),
            ),
            onPressed: (isLoading || !enabled) ? null : onPressed,
            child: isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      color: loadingColor ?? AppStyles.primary,
                      strokeWidth: 2,
                    ),
                  )
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (prefixWidget != null)
                          Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: prefixWidget!,
                          ),
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: AppStyles.subTitle,
                            color: fontColor ?? AppStyles.smoke,
                          ),
                        ),
                        if (suffixIcon != null)
                          Padding(
                            padding: EdgeInsets.only(left: 8.w),
                            child: Icon(
                              suffixIcon,
                              size: 20.w,
                              color: fontColor ??
                                  Colors.white, // ✅ custom icon color too
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
