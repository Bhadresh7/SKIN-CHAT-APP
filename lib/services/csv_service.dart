import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:open_filex/open_filex.dart';

class CsvService {
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  Future<String> fetchUserDetailsAndConvertToCsv({required String role}) async {
    try {
      // Fetch users with the specified role
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _store.collection('users').where('role', isEqualTo: role).get();

      if (querySnapshot.docs.isEmpty) {
        print("No users found with role: $role");
        return "No data found";
      }

      // Convert fetched data to a list for CSV conversion
      List<List<dynamic>> csvData = [
        ["User ID", "Name", "Email", "Role"] // CSV Headers
      ];

      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        csvData.add([
          doc.id, // User document ID
          data["username"] ?? "N/A",
          data["email"] ?? "N/A",
          data["role"] ?? "N/A",
        ]);
      }

      // Convert list to CSV string
      String csvString = const ListToCsvConverter().convert(csvData);

      // Get the public Downloads directory (For Android)
      Directory? directory = Directory('/storage/emulated/0/Download');

      // Ensure the directory exists
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      String filePath = "${directory.path}/user_data.csv";

      // Save CSV file
      File file = File(filePath);
      await file.writeAsString(csvString);

      print("✅ CSV file saved at: $filePath");

      // Open the file (Optional)
      await OpenFilex.open(filePath);

      return filePath;
    } catch (e) {
      print("❌ Error fetching users: $e");
      return "Error";
    }
  }
}
