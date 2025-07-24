class ViewUsersModel {
  ViewUsersModel({
    required this.uid,
    required this.name,
    required this.role,
    required this.email,
    required this.mobileNumber,
    required this.dob,
    required this.isBlocked,
    required this.canPost,
    this.img,
  });

  final String uid;
  final String name;
  final String role;
  final String email;
  final String mobileNumber;
  final String dob;
  final String? img;
  final bool canPost;
  final bool isBlocked;

  factory ViewUsersModel.fromJson(Map<String, dynamic> data) {
    return ViewUsersModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      name: data['username'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      dob: data['dob'] ?? '',
      img: data['imageUrl'] ?? '',
      isBlocked: data['isBlocked'] ?? false,
      canPost: data['canPost'] ?? false,
    );
  }
}
