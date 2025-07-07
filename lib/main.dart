import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_config.dart';
import 'package:skin_chat_app/helpers/notification_helpers.dart';
import 'package:skin_chat_app/providers/exports.dart';
import 'package:skin_chat_app/screens/auth/auth_screen.dart';
import 'package:skin_chat_app/services/hive_service.dart';
import 'package:toastification/toastification.dart';

import 'constants/app_styles.dart';
import 'providers/message/share_content_provider.dart';
import 'providers/super_admin/super_admin_provider_2.dart';
import 'providers/version/app_version_provider.dart';
import 'services/notification_service.dart';

Future<void> runMainApp({required String env}) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables first
  await dotenv.load(fileName: ".env");

  // Set the app environment
  AppConfig.setEnvironment(env);

  // Initialize Hive after dotenv is loaded
  await HiveService.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  // get initial messages
  ChatProvider().initMessageStream();

  // Init notification service
  final NotificationService service = NotificationService();
  await service.initializeNotifications();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationHelpers().requestNotificationPermission();

  print(
      "BASIC USER DETAILS FORM STATUS ${MyAuthProvider().hasCompletedBasicDetails}");
  print("IMAGE SETUP STATUS ${MyAuthProvider().hasCompletedImageSetup}");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InternetProvider()),
        ChangeNotifierProvider(create: (_) => MyAuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => EmailVerificationProvider()),
        ChangeNotifierProvider(create: (_) => BasicUserDetailsProvider()),
        ChangeNotifierProvider(create: (_) => SuperAdminProvider()),
        ChangeNotifierProvider(create: (_) => SharedContentProvider()),
        ChangeNotifierProvider(create: (_) => ShareIntentProvider()),
        ChangeNotifierProvider(create: (_) => SuperAdminProvider2()),
        ChangeNotifierProvider(create: (_) => AppVersionProvider()),
        ChangeNotifierProvider(create: (_) => ImagePickerProvider())
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
        return ToastificationWrapper(
          child: MaterialApp(
            themeMode: ThemeMode.system,
            theme: ThemeData(
              brightness: Brightness.light,
              fontFamily: AppStyles.primaryFont,
              scaffoldBackgroundColor: Colors.white,
            ),
            debugShowCheckedModeBanner: false,
            home: const AuthScreen(),
          ),
        );
      },
    );
  }
}
