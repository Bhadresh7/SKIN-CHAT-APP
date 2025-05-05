import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:skin_chat_app/constants/app_apis.dart';

import '../constants/app_status.dart';

/// 👇 Background handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🌙 Background Notification Received:");
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print(message.data);

  // You can show a heads-up notification here
  NotificationService().showHeadsUpNotification(message);
}

class NotificationService {
  final Dio _dio = Dio();
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// ✅ Call this during app start to initialize notifications
  Future<void> initializeNotifications() async {
    const androidInit = AndroidInitializationSettings('ic_notification');
    const initSettings = InitializationSettings(android: androidInit);

    // await _flutterLocalNotificationsPlugin.initialize(initSettings,
    //     onDidReceiveNotificationResponse: onSelectNotification);

    await _firebaseMessaging.requestPermission();

    // Handling foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🛎️ Foreground Notification Received:");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");
      showNotification(message);
    });

    // Handling background notifications
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🌟 Background Notification Tapped!");
      showNotification(message);
    });
  }

  /// Show normal notification when app is in foreground
  Future<void> showNotification(RemoteMessage message) async {
    try {
      // Create notification details
      const androidDetails = AndroidNotificationDetails(
        'your_channel_id', // channel id
        'your_channel_name', // channel name
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
      );
      const platformDetails = NotificationDetails(android: androidDetails);

      // Show the notification
      await _flutterLocalNotificationsPlugin.show(
        0, // notification id
        message.notification?.title, // title
        message.notification?.body, // body
        platformDetails,
        payload: message.data.toString(),
      );
    } catch (e) {
      print("🔥 Error showing notification: $e");
    }
  }

  /// Show a heads-up notification (poster-like) when app is in background
  Future<void> showHeadsUpNotification(RemoteMessage message) async {
    try {
      // Android notification settings with heads-up notification (full-screen)
      const androidDetails = AndroidNotificationDetails(
        'your_channel_id', // channel id
        'your_channel_name', // channel name
        importance: Importance.max, // Heads-up notification
        priority: Priority.max, // High priority
        ticker: 'ticker',
        fullScreenIntent: true,
      );
      const platformDetails = NotificationDetails(android: androidDetails);

      // Show the notification as a heads-up notification
      await _flutterLocalNotificationsPlugin.show(
        0, // notification id
        message.notification?.title, // title
        message.notification?.body, // body
        platformDetails,
        payload: message.data.toString(),
      );
    } catch (e) {
      print("🔥 Error showing heads-up notification: $e");
    }
  }

  /// 🔐 Store FCM token to Firestore for later use (like sending messages)
  Future<String> storeDeviceToken({required String uid}) async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print("🕊️ Token: $token");

      if (token != null && token.isNotEmpty) {
        DocumentSnapshot doc = await _store.collection('tokens').doc(uid).get();

        if (doc.exists) {
          String? existingToken = doc.get('token');
          if (existingToken == token) {
            print("✅ Token already exists and is up to date.");
            return AppStatus.kSuccess;
          }
        }

        await _store.collection('tokens').doc(uid).set({
          "id": uid,
          "token": token,
        });
        print("✅ Token stored/updated successfully.");
        return AppStatus.kSuccess;
      }

      return AppStatus.kFailed;
    } catch (e) {
      print("🔥 Error getting or storing FCM token: $e");
      return AppStatus.kFailed;
    }
  }

  /// 🚀 Send notification to users using your backend API
  Future<void> sendNotificationToUsers({
    required String title,
    required String content,
  }) async {
    try {
      Response res = await _dio.post(
        AppApis.getNotification,
        data: {
          "title": title,
          "content": content,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      print("🐈 Notification sent: ${res.statusMessage}");
    } catch (e) {
      print("❌ Error sending notification: $e");
    }
  }
}
