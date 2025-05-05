import 'package:bcrypt/bcrypt.dart';

class PasswordHashingHelper {
  static String hashPassword({required String password}) {
    return BCrypt.hashpw(
      password,
      BCrypt.gensalt(),
    );
  }
}
