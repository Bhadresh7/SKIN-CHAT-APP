// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_chat_core/flutter_chat_core.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_sharing_intent/model/sharing_file.dart';
// import 'package:provider/provider.dart';
// import 'package:skin_chat_app/constants/app_assets.dart';
// import 'package:skin_chat_app/constants/app_status.dart';
// import 'package:skin_chat_app/constants/app_styles.dart';
// import 'package:skin_chat_app/helpers/my_navigation.dart';
// import 'package:skin_chat_app/helpers/toast_helper.dart';
// import 'package:skin_chat_app/models/meta_model.dart';
// import 'package:skin_chat_app/providers/exports.dart';
// import 'package:skin_chat_app/providers/message/share_content_provider.dart';
// import 'package:skin_chat_app/screens/auth/login_screen.dart';
// import 'package:skin_chat_app/services/hive_service.dart';
// import 'package:skin_chat_app/services/notification_service.dart';
// import 'package:skin_chat_app/utils/custom_mapper.dart';
// import 'package:skin_chat_app/widgets/common/background_scaffold.dart';
// import 'package:skin_chat_app/widgets/common/custom_message_widget.dart';
// import 'package:skin_chat_app/widgets/common/showDeleteDialog.dart';
// import 'package:uuid/uuid.dart';
//
// import '../../models/chat_message_model.dart';
// import 'image_preview_screen.dart';
//
// class HomeScreenVarient2 extends StatefulWidget {
//   const HomeScreenVarient2({super.key});
//
//   @override
//   State<HomeScreenVarient2> createState() => _HomeScreenVarient2State();
// }
//
// class _HomeScreenVarient2State extends State<HomeScreenVarient2> {
//   late NotificationService service;
//   late TextEditingController messageController;
//
//   // late Stream<Map<String, dynamic>> canPostStream;
//
//   int? maxLines;
//
//   void _updateMaxLines() {
//     setState(() {
//       maxLines = messageController.text.trim().isEmpty ? null : 2;
//       print("MAX LINES VALUE $maxLines");
//     });
//   }
//
//   @override
//   void initState() {
//     print("Hey there init Called");
//
//     super.initState();
//     // canPostStream = context.read<MyAuthProvider>().canPostAccessStream;
//
//     messageController = TextEditingController();
//     service = NotificationService();
//     final chatProvider = Provider.of<ChatProvider>(context, listen: false);
//     final initialMessages = chatProvider.getAllMessagesFromLocalStorage();
//     chatProvider.messageNotifier.value = initialMessages;
//   }
//
//   bool _hasHandledSharedFile = false;
//   bool _hasFetchedLinkMetadata = false;
//   bool _hasControllerInited = false;
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//
//     final shareIntentProvider =
//         Provider.of<ShareIntentProvider>(context, listen: false);
//     final chatProvider = Provider.of<ChatProvider>(context, listen: false);
//     final authProvider = Provider.of<MyAuthProvider>(context, listen: false);
//     final shareContentProvider =
//         Provider.of<SharedContentProvider>(context, listen: false);
//     final sharedFiles = shareIntentProvider.sharedFiles;
//
//     // Initialize controller if user can post
//     if ((authProvider.currentUser?.canPost ?? false) && !_hasControllerInited) {
//       messageController = TextEditingController();
//       _hasControllerInited = true;
//       print("✅ Controller initialized");
//     }
//
//     // Dispose controller if user can't post
//     if (!(authProvider.currentUser?.canPost ?? false) && _hasControllerInited) {
//       messageController.dispose();
//       _hasControllerInited = false;
//       print("❌ Controller disposed");
//     }
//
//     print("==============================");
//     print("SHARED FILES ==>$sharedFiles");
//     if (sharedFiles != null && sharedFiles.isNotEmpty) {
//       print("First shared file: ${sharedFiles[0].value}");
//       print("First shared file type: ${sharedFiles[0].type}");
//     }
//     print("==============================");
//
//     // Only process shared content if user can post
//     if (authProvider.currentUser?.canPost ?? false) {
//       if (!_hasHandledSharedFile &&
//           sharedFiles != null &&
//           sharedFiles.isNotEmpty) {
//         final sendingContent = sharedFiles[0];
//
//         // Check if it's a URL by examining the content
//         final isUrlContent = _isUrl(sendingContent.value ?? "");
//         final isTextContent = sendingContent.type == SharedMediaType.TEXT;
//         final isUrlType = sendingContent.type == SharedMediaType.URL;
//
//         print("Content: ${sendingContent.value}");
//         print("Type: ${sendingContent.type}");
//         print("Is URL content: $isUrlContent");
//         print("Is text type: $isTextContent");
//         print("Is URL type: $isUrlType");
//
//         if (isTextContent || isUrlType || isUrlContent) {
//           // Handle text/URL sharing
//           print("Handling text/URL sharing");
//
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (_hasControllerInited && mounted) {
//               messageController.clear();
//
//               final sharedText = sendingContent.value ?? "";
//               messageController.text = sharedText;
//
//               print("✅ Text prefilled: $sharedText");
//               print(
//                   "✅ Controller text after setting: ${messageController.text}");
//
//               // Force rebuild to ensure UI updates
//               if (mounted) {
//                 setState(() {});
//               }
//             } else {
//               print("❌ Controller not ready or widget not mounted");
//             }
//           });
//         } else {
//           // Handle image/file sharing
//           print("Handling image/file sharing");
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (mounted) {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => ImagePreviewScreen(
//                     image: File(sendingContent.value ?? ""),
//                     onSend: (caption) {
//                       final imgFile = File(sendingContent.value ?? "");
//                       if (caption.trim().isNotEmpty) {
//                         chatProvider.handleImageWithTextMessage(
//                           authProvider,
//                           imgFile,
//                           caption.trim(),
//                         );
//                       } else {
//                         chatProvider.handleImageMessage(authProvider, imgFile);
//                       }
//                       shareIntentProvider.clear();
//                       shareContentProvider.clear();
//                       _hasHandledSharedFile = false;
//                     },
//                   ),
//                 ),
//               );
//             }
//           });
//         }
//       }
//     }
//   }
//
// // Helper method to check if content is a URL
//   bool _isUrl(String content) {
//     final urlRegex = RegExp(
//       r'^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&=]*)$',
//       caseSensitive: false,
//     );
//     return urlRegex.hasMatch(content);
//   }
//
//   @override
//   void dispose() {
//     Future.microtask(() {
//       messageController.dispose();
//     });
//     super.dispose();
//   }
//
//   void _clearController() {
//     messageController.clear();
//   }
//
//   String? extractFirstUrl(String text) {
//     final urlRegex = RegExp(
//       r'(?:(?:https?|ftp)://)?(?:[\w-]+\.)+[a-z]{2,}(?:/\S*)?',
//       caseSensitive: false,
//     );
//
//     final match = urlRegex.firstMatch(text);
//     return match?.group(0);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     /// Providers
//     final chatProvider = Provider.of<ChatProvider>(context);
//     final internetProvider = Provider.of<InternetProvider>(context);
//     final authProvider = Provider.of<MyAuthProvider>(context);
//     final imagePickerProvider = Provider.of<ImagePickerProvider>(context);
//     final shareIntentProvider = Provider.of<ShareIntentProvider>(context);
//     final shareContentProvider = Provider.of<SharedContentProvider>(context);
//     bool hasHandledBlock =
//         false; // Define this in your widget class (stateful widget)
//
//     return PopScope(
//       canPop: false,
//       child: BackgroundScaffold(
//         margin: EdgeInsets.all(0),
//         showDrawer: true,
//         appBar: AppBar(
//           toolbarHeight: 0.09.sh,
//           title: Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               CircleAvatar(
//                 radius: 0.03.sh,
//                 child: Image.asset(AppAssets.logo),
//               ),
//               SizedBox(width: 0.02.sw),
//               StreamBuilder<Map<String, dynamic>>(
//                 stream: authProvider.adminUserCountStream,
//                 builder: (context, snapshot) {
//                   final employeeCount = snapshot.data?["admin"] ?? 0;
//                   final candidateCount = snapshot.data?["user"] ?? 0;
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("S.K.I.N. App"),
//                       Row(
//                         spacing: 0.02.sw,
//                         children: [
//                           Text(
//                             "Employer: ${employeeCount.toString()}",
//                             style: TextStyle(fontSize: AppStyles.bodyText),
//                           ),
//                           Text(
//                             "Candidate: ${candidateCount.toString()}",
//                             style: TextStyle(fontSize: AppStyles.bodyText),
//                           ),
//                         ],
//                       ),
//                     ],
//                   );
//                 },
//               )
//             ],
//           ),
//         ),
//         body: Stack(
//           children: [
//             // Use ValueListenableBuilder to listen to messageNotifier changes
//             ValueListenableBuilder<List<types.Message>>(
//               valueListenable: chatProvider.messageNotifier,
//               builder: (context, messages, child) {
//                 return Chat(
//                   emptyState: messages.isEmpty
//                       ? Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "Welcome to Skin Chats",
//                                 style: TextStyle(
//                                   fontSize: AppStyles.heading,
//                                   color: AppStyles.tertiary,
//                                 ),
//                               ),
//                               Text(
//                                 "Start your journey",
//                                 style: TextStyle(color: AppStyles.tertiary),
//                               ),
//                             ],
//                           ),
//                         )
//                       : null,
//                   theme: DefaultChatTheme(
//                     dateDividerMargin: EdgeInsets.all(0.03.sh),
//                     dateDividerTextStyle: TextStyle(fontSize: 15),
//                     inputBackgroundColor: AppStyles.primary,
//                     inputTextCursorColor: AppStyles.smoke,
//                     inputBorderRadius: BorderRadius.all(Radius.circular(0)),
//                   ),
//                   timeFormat: DateFormat("d/MM/yyyy - hh:mm a "),
//                   inputOptions: InputOptions(
//                     textEditingController: messageController,
//                     sendButtonVisibilityMode: SendButtonVisibilityMode.always,
//                   ),
//                   onMessageLongPress: (context, message) async {
//                     if (internetProvider.connectionStatus ==
//                             AppStatus.kDisconnected ||
//                         internetProvider.connectionStatus == AppStatus.kSlow) {
//                       return ToastHelper.showErrorToast(
//                         context: context,
//                         message: "Please check your internet connection",
//                       );
//                     }
//
//                     ShowDeleteDialog.showDeleteDialog(
//                       context,
//                       message,
//                       chatProvider,
//                       authProvider,
//                     );
//                   },
//                   // onAttachmentPressed: () async {
//                   //   final pickedImagePath =
//                   //       await imagePickerProvider.pickImage();
//                   //
//                   //   if (pickedImagePath == AppStatus.kSuccess &&
//                   //       imagePickerProvider.selectedImage != null) {
//                   //     final imageFile =
//                   //         File(imagePickerProvider.selectedImage!.path);
//                   //
//                   //     Navigator.push(
//                   //       context,
//                   //       MaterialPageRoute(
//                   //         builder: (_) => ImagePreviewScreen(
//                   //           image: imageFile,
//                   //           onSend: (caption) async {
//                   //             final compressedImage =
//                   //                 await imagePickerProvider.compressImage(
//                   //                     imagePickerProvider.selectedImage!);
//                   //
//                   //             if (compressedImage != null) {
//                   //               if (caption.isEmpty) {
//                   //                 await chatProvider.handleImageMessage(
//                   //                   authProvider,
//                   //                   compressedImage,
//                   //                 );
//                   //               } else {
//                   //                 await chatProvider.handleImageWithTextMessage(
//                   //                   authProvider,
//                   //                   compressedImage,
//                   //                   caption,
//                   //                 );
//                   //
//                   //                 await service.sendNotificationToUsers(
//                   //                   title: authProvider.currentUser!.username,
//                   //                   content: "sent an image $caption",
//                   //                   userId: authProvider.currentUser?.uid ?? "",
//                   //                 );
//                   //               }
//                   //               imagePickerProvider.clear();
//                   //             }
//                   //           },
//                   //         ),
//                   //       ),
//                   //     );
//                   //   } else {
//                   //     debugPrint("No image selected.");
//                   //   }
//                   // },
//                   customMessageBuilder: (message, {required messageWidth}) {
//                     return CustomMessageWidget(
//                       key: ValueKey(message.id),
//                       messageData: message.metadata ?? {},
//                       messageWidth: 1.sw,
//                     );
//                   },
//                   messages: messages,
//                   onSendPressed: (message) async {
//                     if (internetProvider.connectionStatus ==
//                             AppStatus.kDisconnected ||
//                         internetProvider.connectionStatus ==
//                             AppStatus.kDisconnected) {
//                       ToastHelper.showErrorToast(
//                         context: context,
//                         message: "Please check your internet connection",
//                       );
//                       return;
//                     }
//
//                     final url = extractFirstUrl(message.text);
//
//                     print("$url------------------------");
//
//                     final metaModel = MetaModel(
//                       img: null,
//                       url: url,
//                       text: message.text,
//                     );
//
//                     final newMessage = ChatMessageModel(
//                       id: Uuid().v4(),
//                       author: types.User(
//                         id: authProvider.uid,
//                         firstName: authProvider.currentUser?.username,
//                       ),
//                       metaModel: metaModel,
//                       createdAt: DateTime.now().millisecondsSinceEpoch,
//                     );
//
//                     print(
//                         "STORE TO LOCAL STORAGE IS CALLED -----------------------");
//
//                     // Add message to ValueNotifier instead of localMessages
//                     final chatMessage =
//                         CustomMapper.mapCustomMessageModalToChatMessage(
//                       userId: authProvider.uid,
//                       newMessage,
//                     );
//
//                     chatProvider.addMessageToNotifier(chatMessage);
//                     await chatProvider.sendMessage(newMessage);
//                     await service.sendNotificationToUsers(
//                         title: authProvider.currentUser?.username ?? "",
//                         content: newMessage.metaModel.text ??
//                             newMessage.metaModel.img ??
//                             newMessage.metaModel.url ??
//                             "",
//                         userId: authProvider.currentUser?.uid ?? "");
//                     shareIntentProvider.clear();
//                     _clearController();
//                     _updateMaxLines();
//                     shareContentProvider.clear();
//                     imagePickerProvider.clear();
//                   },
//                   user: types.User(
//                     firstName: authProvider.currentUser?.username,
//                     id: authProvider.uid,
//                   ),
//                   showUserNames: true,
//                   showUserAvatars: true,
//                   customBottomWidget: StreamBuilder<Map<String, dynamic>>(
//                     stream: authProvider.canPostAccessStream,
//                     builder: (context, snapshot) {
//                       print("I'M EMITTED UI !!!!!!!!");
//                       print("SNAPSHOT DATA${snapshot.data}");
//
//                       final canPost = snapshot.data?['canPost'] ??
//                           authProvider.currentUser?.canPost ??
//                           HiveService.getCurrentUser()?.canPost ??
//                           false;
//
//                       final isBlocked = snapshot.data?['isBlocked'] ?? false;
//
//                       if (isBlocked && hasHandledBlock) {
//                         hasHandledBlock = true; // prevent future triggers
//                         WidgetsBinding.instance.addPostFrameCallback((_) async {
//                           await authProvider.signOut();
//                           if (context.mounted) {
//                             MyNavigation.replace(context, LoginScreen());
//                           }
//                         });
//                       }
//
//                       if (!canPost) return const SizedBox.shrink();
//
//                       return Column(
//                         children: [
//                           Padding(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 10.sp,
//                             ),
//                             child: Container(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 16, vertical: 9),
//                               decoration: BoxDecoration(
//                                 color: AppStyles.primary,
//                                 borderRadius: BorderRadius.circular(50),
//                                 border: Border(
//                                   top: BorderSide(
//                                     color: Colors.grey.shade300,
//                                     width: 1,
//                                   ),
//                                 ),
//                               ),
//                               child: Row(
//                                 children: [
//                                   // Attachment button
//                                   IconButton(
//                                     icon: Icon(Icons.attach_file,
//                                         color: AppStyles.smoke),
//                                     onPressed: () async {
//                                       final pickedImagePath =
//                                           await imagePickerProvider.pickImage();
//
//                                       if (pickedImagePath ==
//                                               AppStatus.kSuccess &&
//                                           imagePickerProvider.selectedImage !=
//                                               null) {
//                                         final imageFile = File(
//                                             imagePickerProvider
//                                                 .selectedImage!.path);
//
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (_) => ImagePreviewScreen(
//                                               image: imageFile,
//                                               onSend: (caption) async {
//                                                 final compressedImage =
//                                                     await imagePickerProvider
//                                                         .compressImage(
//                                                             imagePickerProvider
//                                                                 .selectedImage!);
//
//                                                 if (compressedImage != null) {
//                                                   if (caption.isEmpty) {
//                                                     await chatProvider
//                                                         .handleImageMessage(
//                                                       authProvider,
//                                                       compressedImage,
//                                                     );
//                                                   } else {
//                                                     await chatProvider
//                                                         .handleImageWithTextMessage(
//                                                       authProvider,
//                                                       compressedImage,
//                                                       caption,
//                                                     );
//
//                                                     await service
//                                                         .sendNotificationToUsers(
//                                                       title: authProvider
//                                                               .currentUser
//                                                               ?.username ??
//                                                           "",
//                                                       content:
//                                                           "sent an image $caption",
//                                                       userId: authProvider
//                                                               .currentUser
//                                                               ?.uid ??
//                                                           "",
//                                                     );
//                                                   }
//                                                   imagePickerProvider.clear();
//                                                 }
//                                               },
//                                             ),
//                                           ),
//                                         );
//                                       } else {
//                                         debugPrint("No image selected.");
//                                       }
//                                     },
//                                   ),
//
//                                   // Text field
//                                   Expanded(
//                                     child: TextField(
//                                       onChanged: (values) {
//                                         _updateMaxLines();
//                                       },
//                                       controller: messageController,
//                                       decoration: InputDecoration(
//                                         hintText: "Type a message",
//                                         border: OutlineInputBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(20),
//                                           borderSide: BorderSide.none,
//                                         ),
//                                         contentPadding: EdgeInsets.symmetric(
//                                             horizontal: 16, vertical: 8),
//                                         hintStyle:
//                                             TextStyle(color: AppStyles.smoke),
//                                       ),
//                                       style: TextStyle(color: AppStyles.smoke),
//                                       cursorColor: AppStyles.smoke,
//                                       maxLines: maxLines,
//                                       textCapitalization:
//                                           TextCapitalization.sentences,
//                                     ),
//                                   ),
//
//                                   SizedBox(width: 8),
//
//                                   // Send button
//                                   IconButton(
//                                     icon: Icon(Icons.send,
//                                         color: AppStyles.smoke),
//                                     onPressed: () async {
//                                       final messageText =
//                                           messageController.text.trim();
//                                       if (messageText.isEmpty) return;
//
//                                       if (internetProvider.connectionStatus ==
//                                               AppStatus.kDisconnected ||
//                                           internetProvider.connectionStatus ==
//                                               AppStatus.kSlow) {
//                                         ToastHelper.showErrorToast(
//                                           context: context,
//                                           message:
//                                               "Please check your internet connection",
//                                         );
//                                         return;
//                                       }
//
//                                       final url = extractFirstUrl(messageText);
//
//                                       final metaModel = MetaModel(
//                                         img: null,
//                                         url: url,
//                                         text: messageText,
//                                       );
//
//                                       final newMessage = ChatMessageModel(
//                                         id: Uuid().v4(),
//                                         author: types.User(
//                                           id: authProvider.uid,
//                                           firstName: authProvider
//                                               .currentUser?.username,
//                                         ),
//                                         metaModel: metaModel,
//                                         createdAt: DateTime.now()
//                                             .millisecondsSinceEpoch,
//                                       );
//
//                                       // Add message to ValueNotifier
//                                       final chatMessage = CustomMapper
//                                           .mapCustomMessageModalToChatMessage(
//                                         userId: authProvider.uid,
//                                         newMessage,
//                                       );
//                                       _clearController();
//                                       _updateMaxLines();
//                                       chatProvider
//                                           .addMessageToNotifier(chatMessage);
//                                       await chatProvider
//                                           .sendMessage(newMessage);
//                                       await service.sendNotificationToUsers(
//                                         title: authProvider
//                                                 .currentUser?.username ??
//                                             "",
//                                         content: newMessage.metaModel.text ??
//                                             newMessage.metaModel.img ??
//                                             newMessage.metaModel.url ??
//                                             "",
//                                         userId:
//                                             authProvider.currentUser?.uid ?? "",
//                                       );
//
//                                       shareIntentProvider.clear();
//                                       shareContentProvider.clear();
//                                       imagePickerProvider.clear();
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: AppStyles.padding),
//                         ],
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//
//             /// Upload Progress Overlay
//             ValueListenableBuilder<double?>(
//               valueListenable: chatProvider.uploadProgressNotifier,
//               builder: (context, progress, child) {
//                 if (progress == null) {
//                   return const SizedBox.shrink();
//                 }
//
//                 return Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Card(
//                       elevation: 8,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       color: Colors.white,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 16,
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             CircularProgressIndicator(
//                               value: progress,
//                               backgroundColor: Colors.grey[300],
//                               valueColor:
//                                   AlwaysStoppedAnimation<Color>(Colors.blue),
//                             ),
//                             SizedBox(width: 16),
//                             Text(
//                               "${(progress * 100).toStringAsFixed(0)}% uploaded",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             SizedBox(width: 16),
//                             IconButton(
//                               icon: Icon(Icons.cancel, color: Colors.red),
//                               onPressed: () {
//                                 chatProvider.cancelUpload();
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/helpers/my_navigation.dart';
import 'package:skin_chat_app/helpers/toast_helper.dart';
import 'package:skin_chat_app/models/meta_model.dart';
import 'package:skin_chat_app/providers/exports.dart';
import 'package:skin_chat_app/providers/message/share_content_provider.dart';
import 'package:skin_chat_app/screens/auth/login_screen.dart';
import 'package:skin_chat_app/services/hive_service.dart';
import 'package:skin_chat_app/services/notification_service.dart';
import 'package:skin_chat_app/services/user_service.dart';
import 'package:skin_chat_app/utils/custom_mapper.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';
import 'package:skin_chat_app/widgets/common/custom_message_widget.dart';
import 'package:skin_chat_app/widgets/common/showDeleteDialog.dart';
import 'package:skin_chat_app/widgets/common/skin_text_field.dart';
import 'package:uuid/uuid.dart';

import '../../models/chat_message_model.dart';
import 'image_preview_screen.dart';

class HomeScreenVarient2 extends StatefulWidget {
  const HomeScreenVarient2({super.key});

  @override
  State<HomeScreenVarient2> createState() => _HomeScreenVarient2State();
}

class _HomeScreenVarient2State extends State<HomeScreenVarient2> {
  late NotificationService service;
  late TextEditingController messageController;

  // late Stream<Map<String, dynamic>> canPostAccessStream;

  int? maxLines;
  bool _hasHandledSharedFile = false;
  bool _hasFetchedLinkMetadata = false;
  bool _hasControllerInited = false;
  bool _hasHandledBlock = false;

// Fixed _updateMaxLines method
//   void _updateMaxLines() {
//     if (mounted) {
//       setState(() {
//         maxLines = messageController.text.trim().isEmpty ? null : 2;
//       });
//     }
//   }

// Fixed initState method
  @override
  void initState() {
    super.initState();
    print("Hey there init Called");
    // canPostAccessStream = context.read<MyAuthProvider>().canPostAccessStream;
    messageController = TextEditingController();
    // messageController.addListener(_updateMaxLines);
    // service = NotificationService();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        final initialMessages = chatProvider.getAllMessagesFromLocalStorage();
        chatProvider.messageNotifier.value = initialMessages;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final shareIntentProvider =
        Provider.of<ShareIntentProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<MyAuthProvider>(context, listen: false);
    final shareContentProvider =
        Provider.of<SharedContentProvider>(context, listen: false);
    final sharedFiles = shareIntentProvider.sharedFiles;

    if ((authProvider.currentUser?.canPost ?? false) && !_hasControllerInited) {
      messageController = TextEditingController();
      _hasControllerInited = true;
      print("✅ Controller initialized");
    }

    messageController.clear();
    if (!(authProvider.currentUser?.canPost ?? false) && _hasControllerInited) {
      messageController.dispose();
      _hasControllerInited = false;
      print("❌ Controller disposed");
    }
    print("==============================");
    print("SHARED FILES ==>$sharedFiles");
    print("==============================");

    // Only process shared content if we haven't handled it yet and there's actual content
    if (authProvider.currentUser?.canPost ?? false) {
      if (!_hasHandledSharedFile &&
          sharedFiles != null &&
          sharedFiles.isNotEmpty) {
        final sendingContent = sharedFiles[0];
        final isUrl = sendingContent.type == SharedMediaType.URL;

        // Mark as handled to prevent multiple dialogs/actions
        _hasHandledSharedFile = true;

        print("url$isUrl--$sendingContent");

        if (!isUrl) {
          // Handle image sharing with ImagePreviewScreen
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              final imgFile = File(sendingContent.value ?? "");

              // Get initial text from multiple possible sources
              String initialText = "";

              // Fallback to imageMetadata if no direct text
              if (shareContentProvider.imageMetadata != null &&
                  shareContentProvider.imageMetadata!.isNotEmpty) {
                initialText = shareContentProvider.imageMetadata ?? "";
              }

              print("Initial text for image: '$initialText'");

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImagePreviewScreen(
                    image: imgFile,
                    initialText: initialText.toString(),
                    onSend: (caption) async {
                      // Handle the image with or without caption
                      if (caption.isNotEmpty) {
                        chatProvider.handleImageWithTextMessage(
                          authProvider,
                          imgFile,
                          caption,
                        );
                      } else {
                        chatProvider.handleImageMessage(
                          authProvider,
                          imgFile,
                        );
                      }

                      // Clean up
                      shareIntentProvider.clear();
                      _hasHandledSharedFile = false;
                    },
                  ),
                ),
              ).then((_) {
                // Handle case where user cancels without sending
                if (_hasHandledSharedFile) {
                  shareIntentProvider.clear();
                  _hasHandledSharedFile = false;
                }
              });
            },
          );
        } else {
          // Handle URL sharing (keep existing logic)
          if (!_hasFetchedLinkMetadata) {
            final url = sendingContent.value!;
            _hasFetchedLinkMetadata = true;
            print("controller int - $messageController");
            print("url555555555555555555555555${url}");
            messageController.text = url;
            _hasHandledSharedFile = false;
            _hasFetchedLinkMetadata = false;
          }
        }
      }
    } else {
      // shareContentProvider.clear();
      // shareIntentProvider.clear();
      return;
    }
  }

// Fixed dispose method
  @override
  void dispose() {
    // messageController.removeListener(_updateMaxLines);
    messageController.dispose();
    super.dispose();
  }

// Fixed _clearController method
  void _clearController() {
    if (mounted && _hasControllerInited) {
      messageController.clear();
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

    _clearController();
    // _updateMaxLines();
    chatProvider.addMessageToNotifier(chatMessage);

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
  }

  @override
  Widget build(BuildContext context) {
    /// Providers
    final chatProvider = Provider.of<ChatProvider>(context);
    final internetProvider = Provider.of<InternetProvider>(context);
    final authProvider = Provider.of<MyAuthProvider>(context);
    final imagePickerProvider = Provider.of<ImagePickerProvider>(context);
    final shareIntentProvider = Provider.of<ShareIntentProvider>(context);
    final shareContentProvider = Provider.of<SharedContentProvider>(context);
    final _service = UserService();

    return PopScope(
      canPop: false,
      child: BackgroundScaffold(
        margin: const EdgeInsets.all(0),
        showDrawer: true,
        appBar: AppBar(
          toolbarHeight: 0.09.sh,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 0.03.sh,
                child: Image.asset(AppAssets.logo),
              ),
              SizedBox(width: 0.02.sw),
              StreamBuilder<Map<String, dynamic>>(
                stream: authProvider.adminUserCountStream,
                builder: (context, snapshot) {
                  final employeeCount = snapshot.data?["admin"] ?? 0;
                  final candidateCount = snapshot.data?["user"] ?? 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("S.K.I.N. App"),
                      Row(
                        children: [
                          Text(
                            "Employer: ${employeeCount.toString()}",
                            style: TextStyle(fontSize: AppStyles.bodyText),
                          ),
                          SizedBox(width: 0.02.sw),
                          Text(
                            "Candidate: ${candidateCount.toString()}",
                            style: TextStyle(fontSize: AppStyles.bodyText),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              )
            ],
          ),
        ),
        body: Stack(
          children: [
            // Use ValueListenableBuilder to listen to messageNotifier changes
            ValueListenableBuilder<List<types.Message>>(
              valueListenable: chatProvider.messageNotifier,
              builder: (context, messages, child) {
                return Chat(
                  emptyState: messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Welcome to Skin Chats",
                                style: TextStyle(
                                  fontSize: AppStyles.heading,
                                  color: AppStyles.tertiary,
                                ),
                              ),
                              Text(
                                "Start your journey",
                                style: TextStyle(color: AppStyles.tertiary),
                              ),
                            ],
                          ),
                        )
                      : null,
                  theme: DefaultChatTheme(
                    dateDividerMargin: EdgeInsets.all(0.03.sh),
                    dateDividerTextStyle: const TextStyle(fontSize: 15),
                    inputBackgroundColor: AppStyles.primary,
                    inputTextCursorColor: AppStyles.smoke,
                    inputBorderRadius:
                        const BorderRadius.all(Radius.circular(0)),
                  ),
                  timeFormat: DateFormat("d/MM/yyyy - hh:mm a "),
                  inputOptions: InputOptions(
                    textEditingController: messageController,
                    sendButtonVisibilityMode: SendButtonVisibilityMode.always,
                  ),
                  onMessageLongPress: (context, message) async {
                    if (internetProvider.connectionStatus ==
                            AppStatus.kDisconnected ||
                        internetProvider.connectionStatus == AppStatus.kSlow) {
                      return ToastHelper.showErrorToast(
                        context: context,
                        message: "Please check your internet connection",
                      );
                    }

                    ShowDeleteDialog.showDeleteDialog(
                      context,
                      message,
                      chatProvider,
                      authProvider,
                    );
                  },
                  customMessageBuilder: (message, {required messageWidth}) {
                    return CustomMessageWidget(
                      key: ValueKey(message.id),
                      messageData: message.metadata ?? {},
                      messageWidth: 1.sw,
                    );
                  },
                  messages: messages,
                  onSendPressed: (message) async {
                    if (internetProvider.connectionStatus ==
                            AppStatus.kDisconnected ||
                        internetProvider.connectionStatus == AppStatus.kSlow) {
                      ToastHelper.showErrorToast(
                        context: context,
                        message: "Please check your internet connection",
                      );
                      return;
                    }

                    await _handleSendMessage(
                      message.text,
                      authProvider,
                      chatProvider,
                      service,
                      shareIntentProvider,
                      shareContentProvider,
                      imagePickerProvider,
                    );
                  },
                  user: types.User(
                    firstName: authProvider.currentUser?.username,
                    id: authProvider.uid,
                  ),
                  showUserNames: true,
                  showUserAvatars: true,
                  customBottomWidget: StreamBuilder<Map<String, dynamic>>(
                    stream: _service.fetchRoleAndSaveLocally(),
                    builder: (context, snapshot) {
                      print("I'M EMITTED UI !!!!!!!!");
                      print("SNAPSHOT DATA ${snapshot.data}");

                      final canPost = snapshot.data?['canPost'] ??
                          authProvider.currentUser?.canPost ??
                          HiveService.getCurrentUser()?.canPost ??
                          false;

                      final isBlocked = snapshot.data?['isBlocked'] ?? false;

                      if (isBlocked && !_hasHandledBlock) {
                        _hasHandledBlock = true;
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          await authProvider.signOut();
                          if (context.mounted) {
                            MyNavigation.replace(context, const LoginScreen());
                          }
                        });
                      }

                      if (!canPost) return const SizedBox.shrink();

                      return SkinTextField(
                          messageController: messageController);
                    },
                  ),
                );
              },
            ),

            /// Upload Progress Overlay
            ValueListenableBuilder<double?>(
              valueListenable: chatProvider.uploadProgressNotifier,
              builder: (context, progress, child) {
                if (progress == null) {
                  return const SizedBox.shrink();
                }

                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.blue),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "${(progress * 100).toStringAsFixed(0)}% uploaded",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                chatProvider.cancelUpload();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
