import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/services/hive_service.dart';

import 'constants/app_styles.dart';
import 'helpers/notification_helpers.dart';
import 'providers/exports.dart';
import 'providers/message/share_content_provider.dart';
import 'providers/super_admin/super_admin_provider_2.dart';
import 'providers/version/app_version_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'services/notification_service.dart';

Future<void> runMainApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  /// Load environment variables
  await dotenv.load(fileName: ".env");

  /// Init notification service
  final NotificationService service = NotificationService();
  await service.initializeNotifications();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationHelpers().requestNotificationPermission();

  /// Start the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InternetProvider()),
        ChangeNotifierProvider(create: (_) => MyAuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => EmailVerificationProvider()),
        ChangeNotifierProvider(create: (_) => BasicUserDetailsProvider()),
        ChangeNotifierProvider(create: (_) => ImagePickerProvider()),
        ChangeNotifierProvider(create: (_) => SuperAdminProvider()),
        ChangeNotifierProvider(create: (_) => SharedContentProvider()),
        ChangeNotifierProvider(create: (_) => ShareIntentProvider()),
        ChangeNotifierProvider(create: (_) => SuperAdminProvider2()),
        ChangeNotifierProvider(create: (_) => AppVersionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          themeMode: ThemeMode.system,
          theme: ThemeData(
            brightness: Brightness.light,
            fontFamily: AppStyles.primaryFont,
            scaffoldBackgroundColor: Colors.white,
          ),
          debugShowCheckedModeBanner: false,
          home: const AuthScreen(),
        );
      },
    );
  }
}
