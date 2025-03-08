import 'package:flutter/material.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BackgroundScaffold(
        showDrawer: true,
        appBar: AppBar(),
        body: Column(
          children: [
            Text("This is chat screen"),
          ],
        ),
      ),
    );
  }
}
