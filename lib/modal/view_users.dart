class ViewUsers {
  ViewUsers({
    required this.uid,
    required this.name,
    required this.role,
    required this.email,
    required this.aadharNo,
    required this.mobileNumber,
    required this.dob,
  });

  final String uid;
  final String name;
  final String role;
  final String email;
  final String aadharNo;
  final String mobileNumber;
  final String dob;

  factory ViewUsers.fromJson(Map<String, dynamic> data) {
    return ViewUsers(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      name: data['username'] ?? '',
      aadharNo: data['aadharNo'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      dob: data['dob'] ?? '',
    );
  }
}
