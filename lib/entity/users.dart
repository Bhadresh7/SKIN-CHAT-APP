class Users {
  Users({
    required this.uid,
    required this.username,
    required this.email,
    this.password,
    this.role = "user",
    this.isGoogle,
  });

  final String uid;
  final String username;
  final String email;
  String? password;
  bool? isGoogle;
  String role;

  ///convert the data to map to store in firebase
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      'isGoogle': isGoogle
    };
  }
}
