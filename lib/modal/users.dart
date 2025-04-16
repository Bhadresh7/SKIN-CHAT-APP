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
    this.createdAt,
  });

  final String uid;
  final String username;
  final String email;
  String? password;
  bool? isGoogle;
  final String role;
  final bool isAdmin;
  final bool canPost;
  final bool isBlocked;
  final String aadharNo;
  final String mobileNumber;
  final String dob;
  final Timestamp? createdAt;

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
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// Convert Firestore document to a `Users` object
  factory Users.fromFirestore(Map<String, dynamic> data) {
    return Users(
      uid: data['uid'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      password: data['password'],
      role: data['role'] ?? '',
      isGoogle: data['isGoogle'],
      isAdmin: data['isAdmin'] ?? false,
      canPost: data['canPost'] ?? false,
      isBlocked: data['isBlocked'] ?? false,
      aadharNo: data['aadharNo'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      dob: data['dob'] ?? '',
      createdAt: data['createdAt'],
    );
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
  dob: $dob,
  createdAt: ${createdAt != null ? createdAt!.toDate().toString() : "N/A"}
)''';
  }
}
