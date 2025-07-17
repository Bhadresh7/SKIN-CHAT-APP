import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skin_chat_app/constants/app_db_constants.dart';

class CsvService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String formatDate(dynamic timestamp) {
    if (timestamp == null) return "N/A";

    try {
      DateTime dateTime;

      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is String) {
        dateTime = DateTime.tryParse(timestamp) ?? DateTime.now();
      } else {
        return "Invalid Date";
      }

      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (_) {
      return "Invalid Date";
    }
  }

  Future<String> fetchUserDetailsAndConvertToCsv({
    required String role,
    required StreamController<double> progressController,
  }) async {
    try {
      print("+++++++++++++   Called CSV SERVICE   ++++++++++++");
      if (Platform.isAndroid) {
        final permission = await Permission.storage.request();

        if (permission.isGranted) openAppSettings();
        if (permission.isPermanentlyDenied) openAppSettings();
      }

      Query<Map<String, dynamic>> query =
          _firestore.collection(AppDbConstants.kUserCollection);

      if (role != "all") {
        query = query.where('role', isEqualTo: role);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) return "No data found";

      final csvData = <List<dynamic>>[
        ["User ID", "Name", "Email", "Created-At", "Mobile no"]
      ];

      final total = snapshot.docs.length;

      for (int i = 0; i < total; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();

        csvData.add([
          doc.id,
          data["username"] ?? "N/A",
          data["email"] ?? "N/A",
          formatDate(data["createdAt"]),
          data["mobileNumber"] != null ? '\t${data["mobileNumber"]}' : "N/A",
        ]);

        progressController.add((i + 1) / total);
      }

      final csvString = const ListToCsvConverter().convert(csvData);
      final bytes = Uint8List.fromList(csvString.codeUnits);

      final timestamp = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
      final fileName = "${_sanitizeFileName(role)}_Users_$timestamp.csv";

      // Save the file to the Downloads folder
      final downloadsDirectory = await getDownloadsDirectory();
      if (downloadsDirectory == null) {
        return "Failed to access Downloads directory.";
      }

      final filePath = '${downloadsDirectory.path}/$fileName';
      print("File stored in:$filePath");
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // After saving the file, open it using open_filex
      await OpenFilex.open(filePath);

      return "CSV file saved to Downloads: $filePath";
    } catch (e) {
      return "An error occurred: ${e.toString()}";
    }
  }

  String _sanitizeFileName(String input) {
    return input.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
  }
}
