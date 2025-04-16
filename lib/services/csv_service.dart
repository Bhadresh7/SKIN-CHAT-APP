import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

class CsvService {
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  /// Formats Firestore Timestamp to a readable date.
  String formatDate(dynamic timestamp) {
    if (timestamp == null) return "N/A";

    try {
      DateTime dateTime;
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return "Invalid Date";
      }

      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return "Invalid Date";
    }
  }

  Future<String> fetchUserDetailsAndConvertToCsv({
    required String role,
    required StreamController<double> progressController,
  }) async {
    try {
      if (await _requestPermission()) {
        Query<Map<String, dynamic>> query = _store.collection('users');

        if (role != "all") {
          query = query.where('role', isEqualTo: role);
        }

        QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();

        if (querySnapshot.docs.isEmpty) {
          return "No data found";
        }

        List<List<dynamic>> csvData = [
          [
            "User ID",
            "Name",
            "Email",
            "Role",
            "Created-At",
            "Aadhar no",
            "mobile no"
          ]
        ];

        final totalDocs = querySnapshot.docs.length;
        int processedDocs = 0;

        for (var doc in querySnapshot.docs) {
          var data = doc.data();

          csvData.add([
            doc.id,
            '${data["username"] ?? "N/A"}',
            '${data["email"] ?? "N/A"}',
            '${data["role"] ?? "N/A"}',
            formatDate(data["createdAt"]),
            data["aadharNo"] != null
                ? '\t${data["aadharNo"].toString()}'
                : "N/A",
            data["mobileNumber"] != null
                ? '\t${data["mobileNumber"].toString()}'
                : "N/A",
          ]);

          processedDocs++;
          double progress = processedDocs / totalDocs;
          progressController.add(progress);
        }

        String csvString = const ListToCsvConverter().convert(csvData);
        Directory directory = Directory('/storage/emulated/0/Download');
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }

        final userData = (role == "admin")
            ? "Employee"
            : (role == "user")
                ? "Candidate"
                : "All_Users";

        String formattedDate =
            DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
        String filePath = "${directory.path}/$userData  $formattedDate.csv";

        File file = File(filePath);
        await file.writeAsString(csvString);

        await OpenFilex.open(filePath);
        return filePath;
      } else {
        return "Permission denied";
      }
    } catch (e) {
      return "Error";
    }
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      var status = await Permission.manageExternalStorage.request();

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
      }

      return false;
    }

    return true;
  }
}
