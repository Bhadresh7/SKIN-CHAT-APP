import 'package:intl/intl.dart';

class DateFormaterHelper {
  static DateTime? formatedDate({required String value}) {
    try {
      if (value.trim().isEmpty) return null;
      return DateFormat("dd/MM/yyyy").parse(value);
    } catch (e) {
      print("Date parsing failed: $e");
      return null;
    }
  }
}
