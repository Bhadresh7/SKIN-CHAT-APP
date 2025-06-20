import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:skin_chat_app/constants/app_hive_constants.dart';
import 'package:skin_chat_app/models/chat_message.dart';
import 'package:skin_chat_app/models/meta_model.dart';
import 'package:skin_chat_app/models/users.dart';
import 'package:skin_chat_app/services/fetch_metadata.dart';

import '../models/preview_data_model.dart';

class HiveService {
  // Private constructor
  HiveService._();

  // Singleton instance
  static final HiveService _instance = HiveService._();

  static HiveService get instance => _instance;

  // Box references
  static late Box<Users> _userBox;
  static late Box _authBox;
  static late Box _postingAccessBox;
  static late Box _messageBox;

  // Initialization flag
  static bool _isInitialized = false;

  /// Initialize Hive and open boxes
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();

      // Register adapter if not already registered
      if (!Hive.isAdapterRegistered(0) ||
          !Hive.isAdapterRegistered(1) ||
          !Hive.isAdapterRegistered(2) ||
          !Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(UsersAdapter());
        Hive.registerAdapter(ChatMessageAdapter());
        Hive.registerAdapter(PreviewDataModelAdapter());
        Hive.registerAdapter(MetaModelAdapter());
      }

      // Open boxes
      _userBox = await Hive.openBox<Users>(AppHiveConstants.kUserBox);
      _authBox = await Hive.openBox(AppHiveConstants.kAuthBox);
      _postingAccessBox =
          await Hive.openBox(AppHiveConstants.kPostingStatusBox);
      _messageBox = await Hive.openBox(AppHiveConstants.kMessageBox);

      _isInitialized = true;
      debugPrint("Hive initialized successfully");
      List<ChatMessage> messages = getAllMessages();
      for (var e in messages) {
        print(e.toJson());
      }
    } catch (e) {
      debugPrint("Hive initialization error: $e");
      rethrow;
    }
  }

  /// Ensure Hive is initialized
  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
          "HiveService not initialized. Call HiveService.init() first.");
    }
  }

  // ===================
  // USER DATA OPERATIONS
  // ===================

  /// Save user to Hive
  static Future<void> saveUserToHive({required Users? user}) async {
    if (user == null) return;

    _ensureInitialized();

    try {
      await _userBox.put(AppHiveConstants.kCurrentUserDetails, user);
      debugPrint("User saved successfully to Hive");
      debugPrint(user.toString());
    } catch (e) {
      debugPrint("Error saving user to Hive: $e");
      rethrow;
    }
  }

  /// Get current user from Hive
  static Users? getCurrentUser() {
    _ensureInitialized();

    try {
      return _userBox.get(AppHiveConstants.kCurrentUserDetails);
    } catch (e) {
      debugPrint("Error getting current user from Hive: $e");
      return null;
    }
  }

  /// Clear user data
  static Future<void> clearUserData() async {
    _ensureInitialized();

    try {
      await _userBox.clear();
      debugPrint("User data cleared from Hive");
    } catch (e) {
      debugPrint("Error clearing user data from Hive: $e");
    }
  }

  // ===================
  // AUTH STATE OPERATIONS
  // ===================

  /// Check if user is logged in
  static bool get isLoggedIn {
    _ensureInitialized();
    return _authBox.get(AppHiveConstants.kLoggedIn, defaultValue: false);
  }

  /// Set logged in status
  static Future<void> setLoggedIn(bool value) async {
    _ensureInitialized();
    await _authBox.put(AppHiveConstants.kLoggedIn, value);
  }

  /// Check if email is verified
  static bool get isEmailVerified {
    _ensureInitialized();
    return _authBox.get(AppHiveConstants.kEmailVerified, defaultValue: false);
  }

  /// Set email verified status
  static Future<void> setEmailVerified(bool value) async {
    _ensureInitialized();
    await _authBox.put(AppHiveConstants.kEmailVerified, value);
  }

  /// Check if basic details are completed
  static bool get hasCompletedBasicDetails {
    _ensureInitialized();
    return _authBox.get(AppHiveConstants.kHasCompletedBasicDetails,
        defaultValue: false);
  }

  /// Set basic details completion status
  static Future<void> setHasCompletedBasicDetails(bool value) async {
    _ensureInitialized();
    await _authBox.put(AppHiveConstants.kHasCompletedBasicDetails, value);
  }

  /// Check if image setup is completed
  static bool get hasCompletedImageSetup {
    _ensureInitialized();
    return _authBox.get(AppHiveConstants.kHasCompletedImageSetup,
        defaultValue: false);
  }

  /// Set image setup completion status
  static Future<void> setHasCompletedImageSetup(bool value) async {
    _ensureInitialized();
    await _authBox.put(AppHiveConstants.kHasCompletedImageSetup, value);
  }

  /// Check if user signed in with Google
  static bool get isGoogle {
    _ensureInitialized();
    return _authBox.get(AppHiveConstants.kIsGoogle, defaultValue: false);
  }

  /// Set Google sign-in status
  static Future<void> setIsGoogle(bool value) async {
    _ensureInitialized();
    await _authBox.put(AppHiveConstants.kIsGoogle, value);
  }

  /// Get form username
  static String? get formUserName {
    _ensureInitialized();
    return _authBox.get(AppHiveConstants.kFormUserName);
  }

  /// Set form username
  static Future<void> setFormUserName(String username) async {
    _ensureInitialized();
    await _authBox.put(AppHiveConstants.kFormUserName, username);
  }

  /// Clear auth data
  static Future<void> clearAuthData() async {
    _ensureInitialized();

    try {
      await _authBox.clear();
      debugPrint("Auth data cleared from Hive");
    } catch (e) {
      debugPrint("Error clearing auth data from Hive: $e");
    }
  }

  // ===================
  // POSTING ACCESS OPERATIONS
  // ===================

  /// Get posting access status
  static bool get canPost {
    _ensureInitialized();
    return _postingAccessBox.get(AppHiveConstants.kCanPost,
        defaultValue: false);
  }

  /// Set posting access status
  static Future<void> setCanPost(bool value) async {
    _ensureInitialized();
    await _postingAccessBox.put(AppHiveConstants.kCanPost, value);
  }

  /// Get user role
  static String? get userRole {
    _ensureInitialized();
    return _postingAccessBox.get(AppHiveConstants.kUserRole);
  }

  /// Set user role
  static Future<void> setUserRole(String role) async {
    _ensureInitialized();
    await _postingAccessBox.put(AppHiveConstants.kUserRole, role);
  }

  /// Clear posting access data
  static Future<void> clearPostingAccessData() async {
    _ensureInitialized();

    try {
      await _postingAccessBox.clear();
      debugPrint("Posting access data cleared from Hive");
    } catch (e) {
      debugPrint("Error clearing posting access data from Hive: $e");
    }
  }

// ===================
//  MESSAGE OPERATIONS
// ===================

  /// Save message to Hive with message ID as key
  // static Future<void> saveMessage({required ChatMessage message}) async {
  //   _ensureInitialized();
  //
  //   try {
  //     await _messageBox.put(message.id, message);
  //     print(
  //         "AFTER SAVING THE MESSAGE ----------- ${message.metaModel.toJson()}");
  //   } catch (e) {
  //     debugPrint("Error saving message to Hive: $e");
  //     rethrow;
  //   }
  // }
  static Future<void> saveMessage({required ChatMessage message}) async {
    _ensureInitialized();

    try {
      final url = message.metaModel.url;

      if (url != null &&
          url.isNotEmpty &&
          message.metaModel.previewDataModel == null) {
        final fetchedPreview = await FetchMeta().fetchLinkMetadata(url);
        if (fetchedPreview != null) {
          message.metaModel.previewDataModel = fetchedPreview;
        }
      }

      // Now store the message with embedded metadata
      await _messageBox.put(message.id, message);

      print(
          "AFTER SAVING THE MESSAGE ----------- ${message.metaModel.toJson()}");
    } catch (e) {
      debugPrint("Error saving message to Hive: $e");
      rethrow;
    }
  }

  /// Get all messages from Hive sorted by timestamp
  static List<ChatMessage> getAllMessages() {
    _ensureInitialized();

    try {
      final messages = _messageBox.values.whereType<ChatMessage>().toList();

      if (messages.isEmpty) return [];

      debugPrint("Retrieved ${messages.length} messages from Hive");
      return messages;
    } catch (e) {
      debugPrint("Error getting all messages from Hive: $e");
      return [];
    }
  }

  /// Delete message from Hive by message ID
  static Future<void> deleteMessage(String messageId) async {
    _ensureInitialized();

    if (!_messageBox.isOpen) {
      debugPrint("Box is not open!");
      return;
    }

    if (!_messageBox.containsKey(messageId)) {
      debugPrint("Key $messageId not found in box!");
      debugPrint("Available keys: ${_messageBox.keys}");
      return;
    }

    try {
      await _messageBox.delete(messageId);
      debugPrint("Message deleted successfully from Hive with ID: $messageId");
    } catch (e) {
      debugPrint("Error deleting message from Hive: $e");
      rethrow;
    }
  }

  /// Clear message data
  static Future<void> clearMessageData() async {
    _ensureInitialized();

    try {
      await _messageBox.clear();
      debugPrint("Message data cleared from Hive");
    } catch (e) {
      debugPrint("Error clearing message data from Hive: $e");
      rethrow;
    }
  }

  // ===================
  // UTILITY OPERATIONS
  // ===================

  /// Clear all data from Hive
  static Future<void> clearAllData() async {
    _ensureInitialized();

    try {
      await Future.wait([
        clearUserData(),
        clearAuthData(),
        clearPostingAccessData(),
        clearMessageData(),
      ]);
      debugPrint("All Hive data cleared successfully");
    } catch (e) {
      debugPrint("Error clearing all Hive data: $e");
    }
  }

  /// Close all boxes (call when app is disposing)
  static Future<void> dispose() async {
    try {
      if (_isInitialized) {
        await Future.wait([
          _userBox.close(),
          _authBox.close(),
          _postingAccessBox.close(),
          _messageBox.close(),
        ]);
        _isInitialized = false;
        debugPrint("Hive boxes closed successfully");
      }
    } catch (e) {
      debugPrint("Error closing Hive boxes: $e");
    }
  }
}
