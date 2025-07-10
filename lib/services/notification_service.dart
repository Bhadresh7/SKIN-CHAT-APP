import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:skin_chat_app/constants/app_apis.dart';
import 'package:skin_chat_app/models/notification_model.dart';

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
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // print("🛎️ Foreground Notification Received:");
    // print("Title: ${message.notification?.title}");
    // print("Body: ${message.notification?.body}");
    // showNotification(message);
    // });

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
        0,
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

  Future<String> storeDeviceToken({required String uid}) async {
    try {
      final DatabaseReference ref = FirebaseDatabase.instance.ref("tokens");
      String? token = await _firebaseMessaging.getToken();
      print("🕊️ Token: $token");

      if (token != null && token.isNotEmpty) {
        await ref.child(uid).set(token);
        print("✅ Token stored successfully as uid: token.");
        return AppStatus.kSuccess;
      }

      return AppStatus.kFailed;
    } catch (e) {
      print("🔥 Error storing token: $e");
      return AppStatus.kFailed;
    }
  }

  /// 🚀 Send notification to users using your backend API
  Future<void> sendNotificationToUsers({
    required String title,
    required String content,
    required String userId,
  }) async {
    try {
      final messageModel = NotificationModel(
        uid: userId,
        title: title,
        content: content,
      );

      Response res = await _dio.post(
        AppApis.getNotification,
        data: messageModel.toJson(),
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        print("✅ Notification sent successfully: ${res.statusMessage}");
      } else {
        print("❌ Server responded with: ${res.statusCode}");
        print("❌ Response body: ${res.data}");
      }
    } catch (e) {
      if (e is DioException) {
        print("❌ DioException Details:");
        print("Status Code: ${e.response?.statusCode}");
        // print("Request URL: ${e.requestOptions.uri}");
        print("Response Data: ${e.response?.data}");
        print("Error Message: ${e.message}");
      }
      print("❌ Full Error: $e");
    }
  }
}
