import 'package:cloud_firestore/cloud_firestore.dart';

class TimestampHelper {
  /// Converts Firestore Timestamp to String (ISO8601)
  static String? timestampToString(Timestamp? timestamp) {
    if (timestamp == null) return null;
    return timestamp.toDate().toIso8601String();
  }

  /// Converts String (ISO8601) to Firestore Timestamp
  static Timestamp? stringToTimestamp(String? dateString) {
    if (dateString == null) return null;
    try {
      final dateTime = DateTime.parse(dateString);
      return Timestamp.fromDate(dateTime);
    } catch (e) {
      // Invalid format
      return null;
    }
  }
}
