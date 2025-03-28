import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/providers/auth/basic_user_details_provider.dart';
import 'package:skin_chat_app/providers/auth/email_verification_provider.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';
import 'package:skin_chat_app/providers/image_picker_provider.dart';
import 'package:skin_chat_app/providers/internet_provider.dart';
import 'package:skin_chat_app/providers/message/chat_provider.dart';
import 'package:skin_chat_app/providers/message/share_intent_provider.dart';
import 'package:skin_chat_app/providers/super_admin_provider.dart';
import 'package:skin_chat_app/screens/auth/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp],
  );

  await Firebase.initializeApp();

  SharedPreferences store = await SharedPreferences.getInstance();
  final login = store.getBool("isLoggedIn");
  final email = store.getString("user_email");
  final role = store.getString("role");
  final formUserName = store.getString("userName");
  final imgCompleted = store.getBool('hasCompletedBasicDetails');
  final basicDetailsCompleted = store.getBool('hasCompletedImageSetup');

  print("**********************$formUserName**********************");
  print("👍👍👍👍👍👍$email");
  print("🥳🥳🥳🥳🥳🥳🥳$role");
  print("==========================$login========================");
  print("imgSetupCompletedStatus: $imgCompleted");
  print("basicUserDetailsStatus: $basicDetailsCompleted");
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
          theme: ThemeData(
            fontFamily: AppStyles.primaryFont,
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
    // return ViewUsersScreen();
  }
}
