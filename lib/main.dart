import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skin_chat_app/providers/exports.dart';
import 'package:skin_chat_app/services/notification_service.dart';
import 'package:skin_chat_app/widgets/common/chat_placeholder.dart';

import 'constants/app_styles.dart';
import 'firebase_options.dart';
import 'helpers/notification_helpers.dart';
import 'screens/auth/auth_screen.dart' show AuthScreen;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ],
  );

  ///init the env
  await dotenv.load(fileName: ".env");

  ///init firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ///init notification service
  final NotificationService service = NotificationService();
  await service.initializeNotifications();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationHelpers().requestNotificationPermission();

  ///local storage
  SharedPreferences store = await SharedPreferences.getInstance();
  final login = store.getBool("isLoggedIn");
  final email = store.getString("user_email");
  final role = store.getString("role");
  final formUserName = store.getString("userName");
  final imgCompleted = store.getBool('hasCompletedBasicDetails');
  final basicDetailsCompleted = store.getBool('hasCompletedImageSetup');
  final blocked = store.getBool('isBlocked');

  print("**********************$formUserName**********************");
  print("👍👍👍👍👍👍$email");
  print("🥳🥳🥳🥳🥳🥳🥳$role");
  print("==========================$login========================");
  print("imgSetupCompletedStatus: $imgCompleted");
  print("basicUserDetailsStatus: $basicDetailsCompleted");
  print("Blocked: $blocked");

  ///Providers
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
        ChangeNotifierProvider(create: (_) => ShareIntentProvider()),
      ],
      child: MyApp(),
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
          home: const MyHomePage(title: "Hello there"),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return AuthScreen();
  }
}
