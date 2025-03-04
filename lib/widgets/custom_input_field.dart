import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:skin_chat_app/constants/app_styles.dart';

class CustomInputField extends StatefulWidget {
  final String name;
  final String? initialValue;
  final String hintText;
  final TextInputType keyboardType;
  final List<String? Function(String?)> validators;
  final bool isPassword;
  final TextEditingController? controller;
  final AutovalidateMode autovalidateMode;
  final int? maxLength;
  final ValueChanged<String?>? onChanged;
  final bool showPrefix;

  const CustomInputField({
    super.key,
    this.maxLength,
    required this.name,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    required this.validators,
    this.isPassword = false,
    this.controller,
    this.onChanged,
    this.initialValue,
    this.showPrefix = false,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  _CustomInputFieldState createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: FormBuilderTextField(
        autocorrect: widget.isPassword ? false : true,
        maxLength: widget.maxLength,
        name: widget.name,
        initialValue: widget.initialValue,
        autovalidateMode: widget.autovalidateMode,
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
          fillColor: Colors.white,
          filled: true,
          labelText: widget.hintText,
          labelStyle:
              TextStyle(color: Colors.grey[600], fontSize: AppStyles.hintText),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadius),
            borderSide: BorderSide(
                color: Colors.blue, width: AppStyles.borderThickness),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadius),
            borderSide: BorderSide(
                color: AppStyles.primary, width: AppStyles.borderThickness),
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText; // Toggle visibility
                    });
                  },
                )
              : null,
        ),
        validator: FormBuilderValidators.compose(widget.validators),
        onChanged: widget.onChanged,
      ),
    );
  }
}
