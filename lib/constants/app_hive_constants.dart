class AppHiveConstants {
  // Private constructor to prevent instantiation
  AppHiveConstants._();

  // Box names
  static const String kUserBox = 'user_box';
  static const String kAuthBox = 'auth_box';
  static const String kPostingStatusBox = 'posting_status_box';
  static const String kMessageBox = 'message_box';

  // User box keys
  static const String kCurrentUserDetails = 'current_user_details';

  // Auth box keys
  static const String kLoggedIn = 'is_logged_in';
  static const String kEmailVerified = 'is_email_verified';
  static const String kHasCompletedBasicDetails = 'has_completed_basic_details';
  static const String kHasCompletedImageSetup = 'has_completed_image_setup';
  static const String kIsGoogle = 'is_google';
  static const String kFormUserName = 'form_user_name';

  // Posting status box keys
  static const String kCanPost = 'can_post';
  static const String kUserRole = 'user_role';
}
