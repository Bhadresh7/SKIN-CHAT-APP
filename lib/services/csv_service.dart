import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

class CsvService {
  final FirebaseFirestore _store = FirebaseFirestore.instance;

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
          ["User ID", "Name", "Email", "Role"]
        ];

        final totalDocs = querySnapshot.docs.length;
        int processedDocs = 0;

        for (var doc in querySnapshot.docs) {
          var data = doc.data();

          csvData.add([
            doc.id,
            data["username"] ?? "N/A",
            data["email"] ?? "N/A",
            data["role"] ?? "N/A",
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

        final user_data = (role == "admin")
            ? "Employee"
            : (role == "user")
                ? "Candidate"
                : "All_Users";

        String formattedDate =
            DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
        String filePath = "${directory.path}/$user_data  $formattedDate.csv";

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
