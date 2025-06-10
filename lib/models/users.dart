import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:skin_chat_app/helpers/time_stamp_helper.dart';

part 'users.g.dart';

@HiveType(typeId: 0)
class Users extends HiveObject {
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
    this.imageUrl,
  });

  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String username;
  @HiveField(2)
  final String email;
  @HiveField(3)
  String? password;
  @HiveField(4)
  bool? isGoogle;
  @HiveField(5)
  String role;
  @HiveField(6)
  final bool isAdmin;
  @HiveField(7)
  bool canPost;
  @HiveField(8)
  bool isBlocked;
  @HiveField(9)
  final String aadharNo;
  @HiveField(10)
  final String mobileNumber;
  @HiveField(11)
  final String dob;
  @HiveField(12)
  final String? createdAt;
  @HiveField(13)
  String? imageUrl;

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
      'createdAt': createdAt != null
          ? TimestampHelper.stringToTimestamp(createdAt)
          : FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
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
      createdAt: data['createdAt'] != null
          ? TimestampHelper.timestampToString(data['createdAt'] as Timestamp)
          : null,
      imageUrl: data['imageUrl'],
    );
  }

  @override
  String toString() {
    return '''
Users {
  uid: $uid,
  username: $username,
  email: $email,
  password: ${password ?? 'N/A'},
  isGoogle: ${isGoogle ?? 'N/A'},
  role: $role,
  isAdmin: $isAdmin,
  canPost: $canPost,
  isBlocked: $isBlocked,
  aadharNo: $aadharNo,
  mobileNumber: $mobileNumber,
  dob: $dob,
  createdAt: $createdAt,
  imageUrl: ${imageUrl ?? 'N/A'},
}
''';
  }
}
