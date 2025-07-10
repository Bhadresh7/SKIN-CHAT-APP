import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:skin_chat_app/constants/app_apis.dart';
import 'package:skin_chat_app/constants/app_hive_constants.dart';
import 'package:skin_chat_app/models/chat_message_model.dart';
import 'package:skin_chat_app/models/meta_model.dart';
import 'package:skin_chat_app/models/users_model.dart';

import '../models/preview_data_model.dart';

class HiveService {
  // Private constructor
  HiveService._();

  // Singleton instance
  static final HiveService _instance = HiveService._();

  static HiveService get instance => _instance;

  // Box references
  static late Box<UsersModel> _userBox;
  static late Box _authBox;
  static late Box _postingAccessBox;
  static late Box _messageBox;

  // Initialization flag
  static bool _isInitialized = false;

  // Secure storage for encryption keys
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Generate a secure encryption key
  static Uint8List _generateSecureKey() {
    final random = Random.secure();
    final key = Uint8List(32); // 256-bit key
    for (int i = 0; i < key.length; i++) {
      key[i] = random.nextInt(256);
    }
    return key;
  }

  /// Get or generate encryption key for a specific box
  static Future<Uint8List> _getOrCreateEncryptionKey(String keyName) async {
    try {
      // Try to get existing key
      String? existingKey = await _secureStorage.read(key: keyName);

      if (existingKey != null) {
        // Decode existing key
        return base64Decode(existingKey);
      } else {
        // Generate new key
        final newKey = _generateSecureKey();
        final encodedKey = base64Encode(newKey);

        // Store the key securely
        await _secureStorage.write(key: keyName, value: encodedKey);
        debugPrint("Generated new encryption key for $keyName");

        return newKey;
      }
    } catch (e) {
      debugPrint("Error managing encryption key for $keyName: $e");
      // Fallback: generate a key based on device-specific info
      return _generateFallbackKey(keyName);
    }
  }

  /// Generate a fallback encryption key if secure storage fails
  static Uint8List _generateFallbackKey(String keyName) {
    // Create a deterministic but secure key based on the keyName
    // This ensures the same key is generated each time for the same box
    final bytes = utf8.encode('${keyName}skin_chat_app_fallback_salt');
    final digest = sha256.convert(bytes);
    return Uint8List.fromList(digest.bytes);
  }

  /// Initialize Hive and open encrypted boxes
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();

      // Register adapter if not already registered
      if (!Hive.isAdapterRegistered(0) ||
          !Hive.isAdapterRegistered(1) ||
          !Hive.isAdapterRegistered(2) ||
          !Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(UsersModelAdapter());
        Hive.registerAdapter(ChatMessageAdapter());
        Hive.registerAdapter(PreviewDataModelAdapter());
        Hive.registerAdapter(MetaModelAdapter());
      }

      // Generate encryption keys for each box
      final userBoxKey = await _getOrCreateEncryptionKey(AppApis.encryptionKey);
      final authBoxKey = await _getOrCreateEncryptionKey(AppApis.encryptionKey);
      final postingAccessBoxKey =
          await _getOrCreateEncryptionKey(AppApis.encryptionKey);
      final messageBoxKey =
          await _getOrCreateEncryptionKey(AppApis.encryptionKey);

      // Open encrypted boxes
      _userBox = await Hive.openBox<UsersModel>(
        AppHiveConstants.kUserBox,
        encryptionCipher: HiveAesCipher(userBoxKey),
      );

      _authBox = await Hive.openBox(
        AppHiveConstants.kAuthBox,
        encryptionCipher: HiveAesCipher(authBoxKey),
      );

      _postingAccessBox = await Hive.openBox(
        AppHiveConstants.kPostingStatusBox,
        encryptionCipher: HiveAesCipher(postingAccessBoxKey),
      );

      _messageBox = await Hive.openBox(
        AppHiveConstants.kMessageBox,
        encryptionCipher: HiveAesCipher(messageBoxKey),
      );

      _isInitialized = true;
      debugPrint("Hive initialized successfully with AES encryption");
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

  static Future<bool> isBoxExists() async {
    return await Hive.boxExists(AppHiveConstants.kMessageBox);
  }

  /// Reset encryption keys (use with caution - will make existing data unreadable)
  static Future<void> resetEncryptionKeys() async {
    try {
      await _secureStorage.delete(key: AppApis.encryptionKey);
      await _secureStorage.delete(key: AppApis.encryptionKey);
      await _secureStorage.delete(key: AppApis.encryptionKey);
      await _secureStorage.delete(key: AppApis.encryptionKey);

      debugPrint("All encryption keys have been reset");
    } catch (e) {
      debugPrint("Error resetting encryption keys: $e");
    }
  }

  /// Migrate existing unencrypted data to encrypted boxes
  static Future<void> migrateToEncryptedStorage() async {
    try {
      // Check if unencrypted boxes exist
      final unencryptedUserBoxExists =
          await Hive.boxExists('${AppHiveConstants.kUserBox}_unencrypted');
      final unencryptedAuthBoxExists =
          await Hive.boxExists('${AppHiveConstants.kAuthBox}_unencrypted');
      final unencryptedPostingBoxExists = await Hive.boxExists(
          '${AppHiveConstants.kPostingStatusBox}_unencrypted');
      final unencryptedMessageBoxExists =
          await Hive.boxExists('${AppHiveConstants.kMessageBox}_unencrypted');

      if (!unencryptedUserBoxExists &&
          !unencryptedAuthBoxExists &&
          !unencryptedPostingBoxExists &&
          !unencryptedMessageBoxExists) {
        debugPrint("No unencrypted data found to migrate");
        return;
      }

      debugPrint("Starting migration to encrypted storage...");

      // Migrate user data
      if (unencryptedUserBoxExists) {
        final oldUserBox = await Hive.openBox<UsersModel>(
            '${AppHiveConstants.kUserBox}_unencrypted');
        final userData = oldUserBox.get(AppHiveConstants.kCurrentUserDetails);
        if (userData != null) {
          await saveUserToHive(user: userData);
        }
        await oldUserBox.clear();
        await oldUserBox.close();
      }

      // Similar migration for other boxes...
      debugPrint("Migration to encrypted storage completed");
    } catch (e) {
      debugPrint("Error during migration: $e");
    }
  }

  // ===================
  // USER DATA OPERATIONS
  // ===================

  /// Save user to Hive
  static Future<void> saveUserToHive({required UsersModel? user}) async {
    if (user == null) return;

    _ensureInitialized();

    try {
      await _userBox.put(AppHiveConstants.kCurrentUserDetails, user);
      debugPrint("User saved successfully to encrypted Hive");
      debugPrint(user.toString());
    } catch (e) {
      debugPrint("Error saving user to Hive: $e");
      rethrow;
    }
  }

  /// Get current user from Hive
  static UsersModel? getCurrentUser() {
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

  static Future<int> getLastSavedTimestamp() async {
    final timestampBoxKey =
        await _getOrCreateEncryptionKey('timestamp_box_key');
    final tsBox = await Hive.openBox<int>(
      AppHiveConstants.kTimestampBox,
      encryptionCipher: HiveAesCipher(timestampBoxKey),
    );

    final time = tsBox.get('lastTs', defaultValue: 0) ?? 0;
    print("#################$time");
    return time;
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

  static Future<void> pushMessageToHive(List<ChatMessageModel> messages) async {
    _ensureInitialized();
    for (final message in messages) {
      print("PPPPPPPPPPPPPPPPPPPPPPPPPPP");
      print(message.toJson());
      print("PPPPPPPPPPPPPPPPPPPPPPPPPPP");

      await _messageBox.put(message.id, message); // id must be unique
    }

    print("✅ Stored ${messages.length} messages to encrypted Hive.");
    print(
        "NEW MESSAGES FROM LOCAL STORAGE ---------------- ${messages.length}");
    final data = getAllMessages();

    for (final message in data) {
      print("📩 Message ID: ${message.id}");
      print("📨 Text: ${message.metaModel.toJson()}");
      print("-------------------------");
    }
  }

  static Future<void> saveMessage({required ChatMessageModel message}) async {
    _ensureInitialized();
    try {
      // Save message to encrypted Hive
      await _messageBox.put(message.id, message);
      // print(
      //     "AFTER SAVING THE MESSAGE TO ENCRYPTED LOCAL ----------- ${message.metaModel.toJson()}");

      // ✅ Save/update the latest timestamp with encryption
      final timestampBoxKey =
          await _getOrCreateEncryptionKey('timestamp_box_key');
      final tsBox = await Hive.openBox<int>(
        AppHiveConstants.kTimestampBox,
        encryptionCipher: HiveAesCipher(timestampBoxKey),
      );
      final lastSavedTs = tsBox.get('lastTs', defaultValue: 0) ?? 0;
      final currentMsgTs = message.createdAt;

      if (currentMsgTs > lastSavedTs) {
        await tsBox.put('lastTs', currentMsgTs);
        // print("@@@@@@@@@@@@@@@@@@@@@@@@@@@$currentMsgTs");
      }
    } catch (e) {
      debugPrint("Error saving message to Hive: $e");
      rethrow;
    }
  }

  /// Get all messages from Hive sorted by timestamp
  static List<ChatMessageModel> getAllMessages() {
    _ensureInitialized();

    try {
      final messages =
          _messageBox.values.whereType<ChatMessageModel>().toList();

      if (messages.isEmpty) return [];

      debugPrint("Retrieved ${messages.length} messages from encrypted Hive");
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
      debugPrint(
          "Message deleted successfully from encrypted Hive with ID: $messageId");
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
        // clearMessageData(),
      ]);
      debugPrint("All encrypted Hive data cleared successfully");
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
        debugPrint("Encrypted Hive boxes closed successfully");
      }
    } catch (e) {
      debugPrint("Error closing Hive boxes: $e");
    }
  }

  static Future<Set<String>> getAllMessageIdsSet() async {
    const boxName = AppHiveConstants.kMessageBox;

    if (!Hive.isBoxOpen(boxName)) {
      final messageBoxKey =
          await _getOrCreateEncryptionKey(AppApis.encryptionKey);
      await Hive.openBox<ChatMessageModel>(
        boxName,
        encryptionCipher: HiveAesCipher(messageBoxKey),
      );
    }

    final box = Hive.box(boxName); // Don't use generic here
    return box.values
        .whereType<
            ChatMessageModel>() // Ensure you're getting only valid objects
        .map((msg) => msg.id)
        .toSet();
  }

  // ===================
  // SECURITY UTILITIES
  // ===================

  /// Check if encryption is properly set up
  static Future<bool> isEncryptionEnabled() async {
    try {
      final userBoxKey = await _secureStorage.read(key: AppApis.encryptionKey);
      return userBoxKey != null;
    } catch (e) {
      debugPrint("Error checking encryption status: $e");
      return false;
    }
  }

  /// Get encryption info for debugging (don't use in production)
  static Future<Map<String, bool>> getEncryptionStatus() async {
    if (kDebugMode) {
      return {
        'userBox': await _secureStorage.containsKey(key: AppApis.encryptionKey),
        'authBox': await _secureStorage.containsKey(key: AppApis.encryptionKey),
        'postingAccessBox':
            await _secureStorage.containsKey(key: AppApis.encryptionKey),
        'messageBox':
            await _secureStorage.containsKey(key: AppApis.encryptionKey),
      };
    }
    return {};
  }
}
