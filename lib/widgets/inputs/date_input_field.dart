import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:skin_chat_app/constants/app_styles.dart';

class DateInputField extends StatelessWidget {
  const DateInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            borderRadius: BorderRadius.circular(AppStyles.borderRadius),
          ),
          suffixIcon: Icon(Icons.calendar_today),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
        ),
        validator: FormBuilderValidators.required(
          errorText: "Date of Birth is required",
        ),
      ),
    );
  }
}
