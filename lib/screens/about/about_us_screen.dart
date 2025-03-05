import 'package:flutter/material.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(),
      showDrawer: true,
      body: const Text("About us Screen"),
    );
  }
}
