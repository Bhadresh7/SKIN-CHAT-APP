class AppStatus {
  static const String kConnected = "connected";
  static const String kDisconnected = "disconnected";
  static const String kSlow = "slow";
  static const String kSuccess = "success";
  static const String kFailed = "failed";

  ///AUTH
  static const String kUserNotFound = 'user-not-found';
  static const String kEmailNotFound = 'email-not-found';
  static const String kUserFound = "user-found";
  static const String kTooManyRequests = 'too-many-requests';
  static const String kEmailAlreadyExists = 'email-already-in-use';
  static const String kInternetErrorMsg = 'network-request-failed';

  static const String kEmailNotVerified = 'email-not-verified';
  static const String kBlocked = 'blocked';
  static const String kInvalidCredential = 'invalid-credential';
  static const String kUserNameAlreadyExists = 'user-name-already-exists';

  ///role
  static const String kAdmin = "admin";
  static const String kSuperAdmin = "super_admin";
  static const String kUser = "user";
}
