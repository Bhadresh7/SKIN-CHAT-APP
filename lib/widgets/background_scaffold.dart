import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lottie/lottie.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/helpers/internet_checker_helper.dart';

class BackgroundScaffold extends StatefulWidget {
  const BackgroundScaffold({
    super.key,
    required this.body,
    this.loading = false,
  });

  final Widget body;
  final bool loading;

  @override
  State<BackgroundScaffold> createState() => _BackgroundScaffoldState();
}

class _BackgroundScaffoldState extends State<BackgroundScaffold> {
  late InternetConnectionHelper _internetHelper;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _internetHelper = InternetConnectionHelper();
    _internetHelper.startListening();
    _internetHelper.connectionStatusStream.listen(
      (status) {
        if (mounted) {
          setState(() {
            _isConnected = status == InternetConnectionStatus.connected;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _internetHelper.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return Scaffold(
        body: Center(
            child: Column(
          spacing: 10.sp,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              AppAssets.noInternet,
              width: 300.sp,
            ),
            Text(
              "No Internet connection",
              style: TextStyle(fontSize: AppStyles.heading),
            )
          ],
        )),
      );
    }
    return SafeArea(
      child: Scaffold(
        body: widget.loading
            ? Center(child: CircularProgressIndicator())
            : Container(
                margin: EdgeInsets.symmetric(
                  horizontal: AppStyles.margin,
                  vertical: AppStyles.margin,
                ),
                child: widget.body,
              ),
      ),
    );
  }
}
