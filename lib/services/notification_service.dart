// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dio/dio.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:skin_chat_app/constants/app_apis.dart';
//
// import '../constants/app_status.dart';
//
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("🌙 Background Notification Received:");
//   print("Title: ${message.notification?.title}");t
//   print("Body: ${message.notification?.body}");
//   print(message.data);
// }
//
// class NotificationService {
//   final Dio _dio = Dio();
//   final FirebaseFirestore _store = FirebaseFirestore.instance;
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   /// Call this during app start
//   Future<void> initializeNotifications() async {
//     const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const initSettings = InitializationSettings(android: androidInit);
//
//     await _flutterLocalNotificationsPlugin.initialize(initSettings);
//
//     await _firebaseMessaging.requestPermission();
//
//     // Handle foreground notifications
//      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//        print("🔔 Foreground Notification received:");
//        print("Title: ${message.notification?.title}");
//        print("Body: ${message.notification?.body}");
//
//        _showForegroundNotification(message);
//      });
//   }
//
//   void _showForegroundNotification(RemoteMessage message) {
//     const androidDetails = AndroidNotificationDetails(
//       'default_channel_id',
//       'Default Channel',
//       channelDescription: 'Used for important notifications.',
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//       icon: '@drawable/ic_logo', // custom logo
//     );
//
//     const notificationDetails = NotificationDetails(android: androidDetails);
//
//     _flutterLocalNotificationsPlugin.show(
//       0,
//       message.notification?.title ?? 'No Title',
//       message.notification?.body ?? 'No Body',
//       notificationDetails,
//     );
//   }
//
//   /// Store FCM token to Firestore
//   Future<String> storeDeviceToken({required String uid}) async {
//     try {
//       String? token = await _firebaseMessaging.getToken();
//       print("🕊️ FCM Token: $token");
//
//       if (token != null && token.isNotEmpty) {
//         await _store.collection('tokens').doc(uid).set({
//           "id": uid,
//           "token": token,
//         });
//         return AppStatus.kSuccess;
//       }
//       return AppStatus.kFailed;
//     } catch (e) {
//       print("🔥 Error getting FCM token: $e");
//       return AppStatus.kFailed;
//     }
//   }
//
//   Future<void> sendNotificationToUsers({
//     required String title,
//     required String content,
//   }) async {
//     try {
//       Response res = await _dio.post(
//         AppApis.getNotification,
//         data: {
//           "title": title,
//           "content": content,
//         },
//         options: Options(
//           headers: {
//             "Content-Type": "application/json",
//           },
//         ),
//       );
//       print("🐈 Notification sent: ${res.statusMessage}");
//     } catch (e) {
//       print("❌ Error sending notification: $e");
//     }
//   }
// }

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

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    await _firebaseMessaging.requestPermission();
  }

  /// 🔐 Store FCM token to Firestore for later use (like sending messages)
  Future<String> storeDeviceToken({required String uid}) async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print("🕊️🕊️🕊️🕊️🕊️🕊️🕊️🕊️🕊️🕊️🕊️🕊️ $token");

      if (token != null && token.isNotEmpty) {
        await _store.collection('tokens').doc(uid).set({
          "id": uid,
          "token": token,
        });
        return AppStatus.kSuccess;
      }
      return AppStatus.kFailed;
    } catch (e) {
      print("🔥 Error getting FCM token: $e");
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
