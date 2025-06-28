import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/helpers/my_navigation.dart';
import 'package:skin_chat_app/providers/exports.dart';
import 'package:skin_chat_app/providers/version/app_version_provider.dart';
import 'package:skin_chat_app/screens/screen_exports.dart';
import 'package:skin_chat_app/services/hive_service.dart';

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
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<AppVersionProvider>(context, listen: false).fetchAppVersion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<MyAuthProvider>();

    return SafeArea(
      child: Scaffold(
        appBar: widget.appBar,
        drawer: widget.showDrawer
            ? Drawer(
                child: ListView(
                  children: [
                    UserAccountsDrawerHeader(
                      currentAccountPicture: CircleAvatar(
                        radius: 30,
                        child: authProvider.currentUser?.imageUrl != null &&
                                authProvider.currentUser!.imageUrl!.isNotEmpty
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl:
                                      authProvider.currentUser?.imageUrl ?? "",
                                  fit: BoxFit.cover,
                                  width: 90,
                                  height: 90,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.person),
                                ),
                              )
                            : const Icon(Icons.person, size: 40),
                      ),
                      accountEmail: Text(authProvider.email),
                      accountName: Text(authProvider.currentUser?.username ??
                          HiveService.formUserName ??
                          "User"),
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
                    if (authProvider.currentUser?.role == AppStatus.kSuperAdmin)
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
                      title: Text(
                          ' App version Beta ${context.read<AppVersionProvider>().appVersion}'),
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
                                    MyNavigation.offAll(context, LoginScreen());
                                    await authProvider.signOut();
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
