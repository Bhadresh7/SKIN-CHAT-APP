// part 'users.g.dart';

// @HiveType(typeId: 1)
import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  Users({
    required this.aadharNo,
    required this.mobileNumber,
    required this.uid,
    required this.username,
    required this.email,
    this.password,
    required this.role,
    this.isGoogle,
    this.isAdmin = false,
    this.canPost = false,
    this.isBlocked = false,
    required this.dob,
  });

  // @HiveField(0)
  final String uid;
  // @HiveField(1)
  final String username;
  // @HiveField(2)
  final String email;
  // @HiveField(3)
  String? password;
  // @HiveField(4)
  bool? isGoogle;
  // @HiveField(5)
  final String role;
  // @HiveField(6)
  final bool isAdmin;
  // @HiveField(7)
  final bool canPost;
  // @HiveField(8)
  final bool isBlocked;
  // @HiveField(9)
  final String aadharNo;
  // @HiveField(10)
  final String mobileNumber;
  final String dob;

  /// Convert the data to a map to store in Firebase
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      'isGoogle': isGoogle,
      'isAdmin': isAdmin,
      'canPost': canPost,
      'isBlocked': isBlocked,
      'aadharNo': aadharNo,
      'mobileNumber': mobileNumber,
      'dob': dob,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Method to print the object
  @override
  String toString() {
    return '''
Users(
  uid: $uid,
  username: $username,
  email: $email,
  password: ${password ?? "N/A"},
  role: $role,
  isGoogle: ${isGoogle ?? "N/A"},
  isAdmin: $isAdmin,
  canPost: $canPost,
  isBlocked: $isBlocked,
  aadharNo: $aadharNo,
  mobileNumber: $mobileNumber,
  dob: $dob
)''';
  }
}
