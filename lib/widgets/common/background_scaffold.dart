import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/helpers/my_navigation.dart';
import 'package:skin_chat_app/providers/exports.dart';
import 'package:skin_chat_app/screens/exports.dart';

class BackgroundScaffold extends StatefulWidget {
  const BackgroundScaffold({
    super.key,
    required this.body,
    this.loading = false,
    this.appBar,
    this.showDrawer = false,
    this.margin,
  });

  final Widget body;
  final bool loading;

  final PreferredSizeWidget? appBar;
  final bool showDrawer;
  final EdgeInsetsGeometry? margin;

  @override
  State<BackgroundScaffold> createState() => _BackgroundScaffoldState();
}

class _BackgroundScaffoldState extends State<BackgroundScaffold> {
  @override

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   final role = Provider.of<UserRoleProvider>(context, listen: false);
  //   role.loadUserRole();
  // }
  // late InternetConnectionHelper _internetHelper;
  // bool _isConnected = true;
  //
  // @override
  // void initState() {
  //   super.initState();
  //   _internetHelper = InternetConnectionHelper();
  //   _internetHelper.startListening();
  //   _internetHelper.connectionStatusStream.listen(
  //     (status) {
  //       if (mounted) {
  //         setState(() {
  //           _isConnected = status == InternetConnectionStatus.connected;
  //         });
  //       }
  //     },
  //   );
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _internetHelper.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<MyAuthProvider>();
    // final basicUserDetailsProvider =
    //     Provider.of<BasicUserDetailsProvider>(context);
    // print(authProvider.currentUser?.username);
    // final userRoleProvider = Provider.of<UserRoleProvider>(context);

    // if (!_isConnected) {
    //   return Scaffold(
    //     body: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Lottie.asset(
    //             AppAssets.noInternet,
    //             width: 300.sp,
    //           ),
    //           SizedBox(height: 10.sp),
    //           Text(
    //             "No Internet connection",
    //             style: TextStyle(fontSize: AppStyles.heading),
    //           )
    //         ],
    //       ),
    //     ),
    //   );
    // }

    return SafeArea(
      child: Scaffold(
        appBar: widget.appBar,
        drawer: widget.showDrawer
            ? Drawer(
                child: ListView(
                  children: [
                    UserAccountsDrawerHeader(
                      currentAccountPicture: Image.asset(
                        AppAssets.profileIcon,
                      ),
                      accountEmail: Text(authProvider.email),
                      accountName:
                          Text(authProvider.currentUser?.username ?? "User"),
                    ),
                    ListTile(
                      trailing: Icon(Icons.arrow_forward_ios),
                      title: const Text(' About '),
                      onTap: () {
                        MyNavigation.back(context);
                        MyNavigation.to(context, AboutUsScreen());
                      },
                    ),
                    ListTile(
                      trailing: Icon(Icons.arrow_forward_ios),
                      title: const Text(' Edit Profile '),
                      onTap: () {
                        MyNavigation.back(context);
                        MyNavigation.to(context, EditProfileScreen());
                      },
                    ),
                    if (authProvider.role == AppStatus.kSuperAdmin)
                      ListTile(
                        trailing: Icon(Icons.arrow_forward_ios),
                        title: const Text(' View User '),
                        onTap: () {
                          MyNavigation.back(context);
                          MyNavigation.to(context, ViewUsersScreen());
                        },
                      ),
                    ListTile(
                      title: const Text(' Terms & conditions '),
                      onTap: () {
                        MyNavigation.to(context, TermsAndConditionsScreen());
                      },
                    ),
                    ListTile(
                      title: const Text(' App version Beta 1.0 '),
                      onTap: () {
                        // MyNavigation.to(context, AboutUsScreen());
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.logout_sharp,
                        color: AppStyles.danger,
                      ),
                      title: Text(
                        ' Logout',
                        style: TextStyle(color: AppStyles.danger),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirm Logout"),
                              content: Text("Are you sure to Logout ?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    // print("Nooooo");
                                    MyNavigation.back(context);
                                  },
                                  child: Text("No"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await authProvider.signOut();
                                    if (context.mounted) {
                                      MyNavigation.replace(
                                          context, LoginScreen());
                                    }
                                  },
                                  child: Text("yes"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              )
            : null,
        body: Stack(
          children: [
            Container(
              margin: widget.margin ??
                  EdgeInsets.symmetric(
                    horizontal: AppStyles.margin,
                    vertical: AppStyles.margin,
                  ),
              child: widget.body,
            ),
            if (widget.loading)
              Positioned(
                child: Stack(
                  children: [
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                    Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
