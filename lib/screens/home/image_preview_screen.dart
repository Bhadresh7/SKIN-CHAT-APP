import 'dart:io';

import 'package:flutter/material.dart';
import 'package:skin_chat_app/constants/app_styles.dart';

class ImagePreviewScreen extends StatefulWidget {
  final File image;
  final Function(String) onSend;
  final String? initialText; // Add this parameter

  const ImagePreviewScreen({
    required this.image,
    required this.onSend,
    this.initialText, // Make it optional
    super.key,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set initial text if provided
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      textController.text = widget.initialText!;
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final bottomInset = mediaQuery.viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false, // keep layout fixed
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main image viewer
          InteractiveViewer(
            panEnabled: true,
            minScale: 1.0,
            maxScale: 4.0,
            child: Center(
              child: Image.file(widget.image),
            ),
          ),

          // Close button
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.04,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Caption input that moves with keyboard
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset > 0 ? bottomInset : screenHeight / 15,
            child: Container(
              color: Colors.black54,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03,
                vertical: screenHeight * 0.015,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      cursorColor: AppStyles.smoke,
                      controller: textController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Add a caption...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onSend(textController.text.trim());
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
