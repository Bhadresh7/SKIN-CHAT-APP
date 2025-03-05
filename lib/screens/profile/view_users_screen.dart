import 'package:flutter/material.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';

class ViewUsersScreen extends StatelessWidget {
  const ViewUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(),
      showDrawer: true,
      body: Text("View users screen"),
    );
  }
}
