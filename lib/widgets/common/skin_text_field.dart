import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:uuid/uuid.dart';

import '../../constants/app_status.dart';
import '../../helpers/toast_helper.dart';
import '../../models/chat_message_model.dart';
import '../../models/meta_model.dart';
import '../../providers/exports.dart';
import '../../providers/message/share_content_provider.dart';
import '../../screens/home/image_preview_screen.dart';
import '../../services/notification_service.dart';
import '../../utils/custom_mapper.dart';

class SkinTextField extends StatefulWidget {
  final TextEditingController messageController;

  const SkinTextField({super.key, required this.messageController});

  @override
  State<SkinTextField> createState() => _SkinTextFieldState();
}

class _SkinTextFieldState extends State<SkinTextField> {
  late NotificationService service;
  int? maxLines;

  @override
  void initState() {
    super.initState();
    service = NotificationService();
    // Initialize maxLines
    maxLines = widget.messageController.text.trim().isEmpty ? null : 2;
  }

  // Fixed _updateMaxLines method
  void _updateMaxLines() {
    if (mounted) {
      setState(() {
        maxLines = widget.messageController.text.trim().isEmpty ? null : 2;
      });
    }
  }

  String? extractFirstUrl(String text) {
    final urlRegex = RegExp(
      r'(?:(?:https?|ftp)://)?(?:[\w-]+\.)+[a-z]{2,}(?:/\S*)?',
      caseSensitive: false,
    );

    final match = urlRegex.firstMatch(text);
    return match?.group(0);
  }

  Future<void> _handleSendMessage(
      String messageText,
      MyAuthProvider authProvider,
      ChatProvider chatProvider,
      NotificationService service,
      ShareIntentProvider shareIntentProvider,
      SharedContentProvider shareContentProvider,
      ImagePickerProvider imagePickerProvider) async {
    if (messageText.isEmpty) return;

    // Clear the text field first
    widget.messageController.clear();
    _updateMaxLines();

    final url = extractFirstUrl(messageText);

    final metaModel = MetaModel(
      img: null,
      url: url,
      text: messageText,
    );

    final newMessage = ChatMessageModel(
      id: const Uuid().v4(),
      author: types.User(
        id: authProvider.uid,
        firstName: authProvider.currentUser?.username,
      ),
      metaModel: metaModel,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    // Add message to ValueNotifier
    final chatMessage = CustomMapper.mapCustomMessageModalToChatMessage(
      userId: authProvider.uid,
      newMessage,
    );

    chatProvider.addMessageToNotifier(chatMessage);

    try {
      await chatProvider.sendMessage(newMessage);
      await service.sendNotificationToUsers(
        title: authProvider.currentUser?.username ?? "",
        content: newMessage.metaModel.text ??
            newMessage.metaModel.img ??
            newMessage.metaModel.url ??
            "",
        userId: authProvider.currentUser?.uid ?? "",
      );

      shareIntentProvider.clear();
      shareContentProvider.clear();
      imagePickerProvider.clear();
    } catch (e) {
      debugPrint("Error sending message: $e");
      ToastHelper.showErrorToast(
        context: context,
        message: "Failed to send message. Please try again.",
      );
    }
  }

  Future<void> _handleAttachmentPressed() async {
    final authProvider = context.read<MyAuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final imagePickerProvider = context.read<ImagePickerProvider>();

    final pickedImagePath = await imagePickerProvider.pickImage();

    if (pickedImagePath == AppStatus.kSuccess &&
        imagePickerProvider.selectedImage != null) {
      final imageFile = File(imagePickerProvider.selectedImage!.path);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImagePreviewScreen(
              image: imageFile,
              onSend: (caption) async {
                final compressedImage = await imagePickerProvider
                    .compressImage(imagePickerProvider.selectedImage!);

                if (compressedImage != null) {
                  try {
                    if (caption.isEmpty) {
                      await chatProvider.handleImageMessage(
                        authProvider,
                        compressedImage,
                      );
                    } else {
                      await chatProvider.handleImageWithTextMessage(
                        authProvider,
                        compressedImage,
                        caption,
                      );

                      await service.sendNotificationToUsers(
                        title: authProvider.currentUser?.username ?? "",
                        content: "sent an image $caption",
                        userId: authProvider.currentUser?.uid ?? "",
                      );
                    }
                    imagePickerProvider.clear();
                  } catch (e) {
                    debugPrint("Error sending image: $e");
                    if (mounted) {
                      ToastHelper.showErrorToast(
                        context: context,
                        message: "Failed to send image. Please try again.",
                      );
                    }
                  }
                }
              },
            ),
          ),
        );
      }
    } else {
      debugPrint("No image selected.");
    }
  }

  Future<void> _handleSendPressed() async {
    final messageText = widget.messageController.text.trim();
    if (messageText.isEmpty) return;

    final internetProvider = context.read<InternetProvider>();
    final authProvider = context.read<MyAuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final shareIntentProvider = context.read<ShareIntentProvider>();
    final shareContentProvider = context.read<SharedContentProvider>();
    final imagePickerProvider = context.read<ImagePickerProvider>();

    if (internetProvider.connectionStatus == AppStatus.kDisconnected ||
        internetProvider.connectionStatus == AppStatus.kSlow) {
      ToastHelper.showErrorToast(
        context: context,
        message: "Please check your internet connection",
      );
      return;
    }

    await _handleSendMessage(
      messageText,
      authProvider,
      chatProvider,
      service,
      shareIntentProvider,
      shareContentProvider,
      imagePickerProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.sp),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: AppStyles.primary,
              borderRadius: BorderRadius.circular(50),
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  icon: Icon(Icons.attach_file, color: AppStyles.smoke),
                  onPressed: _handleAttachmentPressed,
                ),

                // Text field
                Expanded(
                  child: TextField(
                    onChanged: (values) {
                      _updateMaxLines();
                    },
                    controller: widget.messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      hintStyle: TextStyle(color: AppStyles.smoke),
                    ),
                    style: TextStyle(color: AppStyles.smoke),
                    cursorColor: AppStyles.smoke,
                    maxLines: maxLines,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                IconButton(
                  icon: Icon(Icons.send, color: AppStyles.smoke),
                  onPressed: _handleSendPressed,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppStyles.padding),
      ],
    );
  }
}
