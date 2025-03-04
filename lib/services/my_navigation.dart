import 'package:flutter/material.dart';

class MyNavigation {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void to(BuildContext? context, Widget screen) {
    Navigator.push(context ?? navigatorKey.currentContext!,
        MaterialPageRoute(builder: (context) => screen));
  }

  static void offAll(BuildContext context, Widget screen) {
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => screen), (route) => false);
  }

  static void back(BuildContext context) {
    Navigator.of(context).pop();
  }

  static void replace(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (context, animation1, animation2) => screen),
    );
  }
}
