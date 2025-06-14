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
// import 'package:skin_chat_app/models/chat_message.dart';
// import 'package:skin_chat_app/models/meta_model.dart';
// import 'package:skin_chat_app/providers/exports.dart';
// import 'package:skin_chat_app/providers/message/share_content_provider.dart';
// import 'package:skin_chat_app/services/notification_service.dart';
// import 'package:skin_chat_app/utils/custom_mapper.dart';
// import 'package:skin_chat_app/widgets/common/background_scaffold.dart';
// import 'package:skin_chat_app/widgets/common/custom_message_widget.dart';
// import 'package:skin_chat_app/widgets/common/showDeleteDialog.dart';
// import 'package:uuid/uuid.dart';
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
//   List<types.CustomMessage> localMessages = [];
//   @override
//   void initState() {
//     super.initState();
//     messageController = TextEditingController();
//     service = NotificationService();
//     final chatProvider = Provider.of<ChatProvider>(context, listen: false);
//     final initialMessages = chatProvider.getAllMessagesFromLocalStorage();
//     localMessages = initialMessages;
//   }
//
//   bool _hasHandledSharedFile = false;
//   bool _hasFetchedLinkMetadata = false;
//   bool _hasControllerInited = false;
//
//   @override
//   void didChangeDependencies() {
//     final TextEditingController captionController = TextEditingController();
//
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
//     if ((authProvider.currentUser?.canPost ?? false) && !_hasControllerInited) {
//       messageController = TextEditingController();
//       _hasControllerInited = true;
//       print("✅ Controller initialized");
//     }
//
//     if (!(authProvider.currentUser?.canPost ?? false) && _hasControllerInited) {
//       messageController.dispose();
//       _hasControllerInited = false;
//       print("❌ Controller disposed");
//     }
//     print("==============================");
//     print("SHARED FILES ==>$sharedFiles");
//     print("==============================");
//
//     // Only process shared content if we haven't handled it yet and there's actual content
//     if (authProvider.currentUser?.canPost ?? false) {
//       if (!_hasHandledSharedFile &&
//           sharedFiles != null &&
//           sharedFiles.isNotEmpty) {
//         final sendingContent = sharedFiles[0];
//         final isUrl = sendingContent.type == SharedMediaType.URL;
//
//         // Mark as handled to prevent multiple dialogs/actions
//         _hasHandledSharedFile = true;
//
//         print("url$isUrl--$sendingContent");
//
//         if (!isUrl) {
//           // Handle image sharing
//           WidgetsBinding.instance.addPostFrameCallback(
//             (_) {
//               showDialog(
//                 context: context,
//                 builder: (_) => AlertDialog(
//                   title: Text('Send this image?'),
//                   content: SingleChildScrollView(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Image.file(
//                           File(sendingContent.value ?? ""),
//                           height: 300,
//                         ),
//                         if (shareContentProvider.imageMetadata != null)
//                           Container(
//                             height: 200,
//                             margin: EdgeInsets.only(top: 16),
//                             padding: EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.grey.shade300),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: TextField(
//                               controller: captionController
//                                 ..text =
//                                     shareContentProvider.imageMetadata ?? "",
//                               maxLines: null,
//                               textAlign: TextAlign.justify,
//                               style: TextStyle(fontSize: 14),
//                               decoration: InputDecoration.collapsed(
//                                 hintText: 'Add a caption...',
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         _hasHandledSharedFile = false;
//                         shareIntentProvider.clear();
//                       },
//                       child: Text('Cancel'),
//                     ),
//                     TextButton(
//                       onPressed: () async {
//                         Navigator.pop(context);
//                         File imgFile = File(sendingContent.value ?? "");
//                         final editedCaption = captionController.text.trim();
//                         if (editedCaption.isNotEmpty) {
//                           chatProvider.handleImageWithTextMessage(
//                             authProvider,
//                             imgFile,
//                             editedCaption,
//                           );
//                         } else {
//                           chatProvider.handleImageMessage(
//                               authProvider, imgFile);
//                         }
//                         shareIntentProvider.clear();
//                         _hasHandledSharedFile = false;
//                       },
//                       child: Text('Send'),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         } else {
//           // Handle URL sharing
//           if (!_hasFetchedLinkMetadata) {
//             final url = sendingContent.value!;
//             _hasFetchedLinkMetadata = true;
//             print("controller int - $messageController");
//             print("url555555555555555555555555${url}");
//             messageController.text = url;
//             _hasHandledSharedFile = false;
//             _hasFetchedLinkMetadata = false;
//           }
//         }
//       }
//     } else {
//       // shareContentProvider.clear();
//       // shareIntentProvider.clear();
//       return;
//     }
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
//                   if (snapshot.hasError) {
//                     print(snapshot.error);
//                   }
//                   final employeeCount = snapshot.data?["admin"] ?? 0;
//                   final candidateCount = snapshot.data?["user"] ?? 0;
//
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("S.K.I.N. App"),
//                       Row(
//                         spacing: 0.02.sw,
//                         children: [
//                           Text(
//                             "Employer: $employeeCount",
//                             style: TextStyle(fontSize: AppStyles.bodyText),
//                           ),
//                           Text(
//                             "Candidate: $candidateCount",
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
//             // StreamBuilder<List<types.Message>>(
//             //   stream: chatProvider.messagesStream,
//             //   builder: (context, snapshot) {
//             //     final isLoading =
//             //         snapshot.connectionState == ConnectionState.waiting;
//             //     // final messages = snapshot.data ?? [];
//             //
//             //     print(
//             //         "--------------------------------------------------------------------------------------------------------------------");
//             //     // messages.forEach((message) => print(message.toJson()));
//             //     print(
//             //         "--------------------------------------------------------------------------------------------------------------------");
//             //     // final messages = chatProvider
//             //     //     .getAllMessagesFromLocalStorage()
//             //     //     .cast<types.Message>();
//             //
//             //   },
//             // ),
//             Chat(
//               // emptyState: isLoading
//               //     ? ChatPlaceholder()
//               //     : Center(
//               //         child: Column(
//               //           mainAxisAlignment: MainAxisAlignment.center,
//               //           children: [
//               //             Text(
//               //               "Welcome to Skin Chats",
//               //               style: TextStyle(
//               //                 fontSize: AppStyles.heading,
//               //                 color: AppStyles.tertiary,
//               //               ),
//               //             ),
//               //             Text(
//               //               "Start your journey",
//               //               style: TextStyle(color: AppStyles.tertiary),
//               //             ),
//               //           ],
//               //         ),
//               //       ),
//               theme: DefaultChatTheme(
//                 sentMessageBodyTextStyle: TextStyle(
//                   fontSize: AppStyles.msgText,
//                   color: AppStyles.smoke,
//                 ),
//                 receivedMessageBodyTextStyle:
//                     TextStyle(fontSize: AppStyles.msgText),
//                 dateDividerMargin: EdgeInsets.all(0.03.sh),
//                 dateDividerTextStyle: TextStyle(fontSize: 15),
//                 userAvatarTextStyle: TextStyle(
//                   fontWeight: FontWeight.normal,
//                   color: AppStyles.smoke,
//                 ),
//                 receivedMessageBodyLinkTextStyle: TextStyle(
//                   color: AppStyles.links,
//                   decoration: TextDecoration.underline,
//                   decorationColor: AppStyles.links,
//                 ),
//                 inputBackgroundColor: AppStyles.primary,
//                 inputTextCursorColor: AppStyles.smoke,
//                 inputBorderRadius: BorderRadius.all(Radius.circular(0)),
//                 sentMessageBodyLinkTextStyle: TextStyle(
//                   color: AppStyles.smoke,
//                   decoration: TextDecoration.underline,
//                   decorationColor: AppStyles.smoke,
//                 ),
//               ),
//               timeFormat: DateFormat("d/MM/yyyy - hh:mm a "),
//               inputOptions: InputOptions(
//                 textEditingController: messageController,
//                 sendButtonVisibilityMode: SendButtonVisibilityMode.always,
//               ),
//               onMessageLongPress: (context, message) {
//                 Showdeletedialog.showDeleteDialog(
//                     context, message, chatProvider, authProvider);
//               },
//               onAttachmentPressed: () async {
//                 final pickedImagePath = await imagePickerProvider.pickImage();
//
//                 if (pickedImagePath == AppStatus.kSuccess &&
//                     imagePickerProvider.selectedImage != null) {
//                   final TextEditingController textController =
//                       TextEditingController();
//
//                   showDialog(
//                     context: context,
//                     builder: (_) => AlertDialog(
//                       title: const Text('Send this image?'),
//                       content: SingleChildScrollView(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Image.file(
//                               File(imagePickerProvider.selectedImage!.path),
//                               height: 300,
//                             ),
//                             const SizedBox(height: 16),
//                             TextField(
//                               controller: textController,
//                               decoration: const InputDecoration(
//                                 hintText: 'Enter a message (optional)',
//                                 border: OutlineInputBorder(),
//                               ),
//                               maxLines: 5,
//                             ),
//                           ],
//                         ),
//                       ),
//                       actions: [
//                         TextButton(
//                           onPressed: () {
//                             MyNavigation.back(context);
//                             imagePickerProvider.clear();
//                           },
//                           child: const Text('Cancel'),
//                         ),
//                         TextButton(
//                           onPressed: () async {
//                             MyNavigation.back(context);
//
//                             final compressedImage =
//                                 await imagePickerProvider.compressImage(
//                                     imagePickerProvider.selectedImage!);
//
//                             if (compressedImage != null &&
//                                 textController.text.isEmpty) {
//                               await chatProvider.handleImageMessage(
//                                 authProvider,
//                                 compressedImage,
//                               );
//
//                               // await service.sendNotificationToUsers(
//                               //   title: authProvider.currentUser!.username,
//                               //   content: "sent an image",
//                               // );
//
//                               imagePickerProvider.clear();
//                             } else {
//                               await chatProvider.handleImageWithTextMessage(
//                                 authProvider,
//                                 compressedImage!,
//                                 textController.text.trim(),
//                               );
//                               await service.sendNotificationToUsers(
//                                 title: authProvider.currentUser!.username,
//                                 content: "sent an image "
//                                     " ${textController.text.trim()}",
//                               );
//                               imagePickerProvider.clear();
//                             }
//                           },
//                           child: const Text('Send'),
//                         ),
//                       ],
//                     ),
//                   );
//                 } else {
//                   debugPrint("No image selected.");
//                 }
//               },
//               customMessageBuilder: (message, {required messageWidth}) {
//                 return CustomMessageWidget(
//                   messageData: message.metadata ?? {},
//                   messageWidth: 1.sw,
//                 );
//               },
//               messages: localMessages,
//               onSendPressed: (message) async {
//                 if (internetProvider.connectionStatus ==
//                         AppStatus.kDisconnected ||
//                     internetProvider.connectionStatus ==
//                         AppStatus.kDisconnected) {
//                   ToastHelper.showErrorToast(
//                     context: context,
//                     message: "Please check your internet connection",
//                   );
//                   return;
//                 }
//
//                 final url = extractFirstUrl(message.text);
//
//                 print("$url------------------------");
//
//                 final metaModel = MetaModel(
//                   img: null,
//                   url: url,
//                   text: message.text,
//                 );
//                 // final newMessage = ChatMessage(
//                 //   id: Uuid().v4(),
//                 //   author: types.User(id: authProvider.uid),
//                 //   metaModel: metaModel,
//                 // );
//                 final newMessage = ChatMessage(
//                   id: Uuid().v4(),
//                   author: types.User(id: authProvider.uid),
//                   metaModel: metaModel,
//                   createdAt: DateTime.now().millisecondsSinceEpoch,
//                 );
//
//                 print(
//                     "STORE TO LOCAL STORAGE IS CALLED -----------------------");
//                 localMessages.add(
//                   CustomMapper.mapCustomMessageModalToChatMessage(
//                     userId: authProvider.uid,
//                     newMessage,
//                   ),
//                 );
//                 setState(() {});
//                 chatProvider.sendMessage(newMessage);
//                 shareIntentProvider.clear();
//                 _clearController();
//                 shareContentProvider.clear();
//                 imagePickerProvider.clear();
//
//                 // await service.sendNotificationToUsers(
//                 //   title: authProvider.currentUser?.username ?? "user",
//                 //   content: customMessage.text.toString(),
//                 // );
//               },
//               user: types.User(
//                 firstName: authProvider.currentUser?.username,
//                 id: authProvider.uid,
//               ),
//               showUserNames: true,
//               showUserAvatars: true,
//               customBottomWidget: authProvider.currentUser?.canPost ?? false
//                   ? null
//                   : const SizedBox.shrink(),
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
import 'package:flutter/services.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/constants/app_assets.dart';
import 'package:skin_chat_app/constants/app_status.dart';
import 'package:skin_chat_app/constants/app_styles.dart';
import 'package:skin_chat_app/helpers/my_navigation.dart';
import 'package:skin_chat_app/helpers/toast_helper.dart';
import 'package:skin_chat_app/models/chat_message.dart';
import 'package:skin_chat_app/models/meta_model.dart';
import 'package:skin_chat_app/providers/exports.dart';
import 'package:skin_chat_app/providers/message/share_content_provider.dart';
import 'package:skin_chat_app/services/notification_service.dart';
import 'package:skin_chat_app/utils/custom_mapper.dart';
import 'package:skin_chat_app/widgets/common/background_scaffold.dart';
import 'package:skin_chat_app/widgets/common/custom_message_widget.dart';
import 'package:skin_chat_app/widgets/common/showDeleteDialog.dart';
import 'package:uuid/uuid.dart';

class HomeScreenVarient2 extends StatefulWidget {
  const HomeScreenVarient2({super.key});

  @override
  State<HomeScreenVarient2> createState() => _HomeScreenVarient2State();
}

class _HomeScreenVarient2State extends State<HomeScreenVarient2> {
  late NotificationService service;
  late TextEditingController messageController;
  ValueNotifier<List<types.CustomMessage>> messageNotifier = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
    service = NotificationService();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final initialMessages = chatProvider.getAllMessagesFromLocalStorage();
    messageNotifier.value = initialMessages;
  }

  bool _hasHandledSharedFile = false;
  bool _hasFetchedLinkMetadata = false;
  bool _hasControllerInited = false;

  @override
  void didChangeDependencies() {
    final TextEditingController captionController = TextEditingController();

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
          // Handle image sharing
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Send this image?'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.file(
                          File(sendingContent.value ?? ""),
                          height: 300,
                        ),
                        if (shareContentProvider.imageMetadata != null)
                          Container(
                            height: 200,
                            margin: EdgeInsets.only(top: 16),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: captionController
                                ..text =
                                    shareContentProvider.imageMetadata ?? "",
                              maxLines: null,
                              textAlign: TextAlign.justify,
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration.collapsed(
                                hintText: 'Add a caption...',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _hasHandledSharedFile = false;
                        shareIntentProvider.clear();
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        File imgFile = File(sendingContent.value ?? "");
                        final editedCaption = captionController.text.trim();
                        if (editedCaption.isNotEmpty) {
                          chatProvider.handleImageWithTextMessage(
                            authProvider,
                            imgFile,
                            editedCaption,
                          );
                        } else {
                          chatProvider.handleImageMessage(
                              authProvider, imgFile);
                        }
                        shareIntentProvider.clear();
                        _hasHandledSharedFile = false;
                      },
                      child: Text('Send'),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          // Handle URL sharing
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

  @override
  void dispose() {
    messageNotifier.dispose(); // Don't forget to dispose the ValueNotifier
    Future.microtask(() {
      messageController.dispose();
    });
    super.dispose();
  }

  void _clearController() {
    messageController.clear();
  }

  String? extractFirstUrl(String text) {
    final urlRegex = RegExp(
      r'(?:(?:https?|ftp)://)?(?:[\w-]+\.)+[a-z]{2,}(?:/\S*)?',
      caseSensitive: false,
    );

    final match = urlRegex.firstMatch(text);
    return match?.group(0);
  }

  void _addMessageToNotifier(types.CustomMessage message) {
    final currentMessages =
        List<types.CustomMessage>.from(messageNotifier.value);
    currentMessages.insert(0, message);
    messageNotifier.value = currentMessages;
  }

  void _removeMessageFromNotifier(String messageId) {
    final currentMessages =
        List<types.CustomMessage>.from(messageNotifier.value);
    currentMessages.removeWhere((message) => message.id == messageId);
    messageNotifier.value = currentMessages;
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

    return PopScope(
      canPop: false,
      child: BackgroundScaffold(
        margin: EdgeInsets.all(0),
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
                      Text("S.K.I.N. App"),
                      Row(
                        spacing: 0.02.sw,
                        children: [
                          Text(
                            "Employer: ${employeeCount.toString()}",
                            style: TextStyle(fontSize: AppStyles.bodyText),
                          ),
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
              valueListenable: messageNotifier,
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
                    sentMessageBodyTextStyle: TextStyle(
                      fontSize: AppStyles.msgText,
                      color: AppStyles.smoke,
                    ),
                    receivedMessageBodyTextStyle:
                        TextStyle(fontSize: AppStyles.msgText),
                    dateDividerMargin: EdgeInsets.all(0.03.sh),
                    dateDividerTextStyle: TextStyle(fontSize: 15),
                    userAvatarTextStyle: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: AppStyles.smoke,
                    ),
                    receivedMessageBodyLinkTextStyle: TextStyle(
                      color: AppStyles.links,
                      decoration: TextDecoration.underline,
                      decorationColor: AppStyles.links,
                    ),
                    inputBackgroundColor: AppStyles.primary,
                    inputTextCursorColor: AppStyles.smoke,
                    inputBorderRadius: BorderRadius.all(Radius.circular(0)),
                    sentMessageBodyLinkTextStyle: TextStyle(
                      color: AppStyles.smoke,
                      decoration: TextDecoration.underline,
                      decorationColor: AppStyles.smoke,
                    ),
                  ),
                  timeFormat: DateFormat("d/MM/yyyy - hh:mm a "),
                  inputOptions: InputOptions(
                    textEditingController: messageController,
                    sendButtonVisibilityMode: SendButtonVisibilityMode.always,
                  ),
                  onMessageLongPress: (context, message) async {
                    print("Vibration triggered");
                    await HapticFeedback.lightImpact();
                    Showdeletedialog.showDeleteDialog(
                        context, message, chatProvider, authProvider);
                    _removeMessageFromNotifier(message.id);
                  },
                  onAttachmentPressed: () async {
                    final pickedImagePath =
                        await imagePickerProvider.pickImage();

                    if (pickedImagePath == AppStatus.kSuccess &&
                        imagePickerProvider.selectedImage != null) {
                      final TextEditingController textController =
                          TextEditingController();

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Send this image?'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.file(
                                  File(imagePickerProvider.selectedImage!.path),
                                  height: 300,
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: textController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter a message (optional)',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 5,
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                MyNavigation.back(context);
                                imagePickerProvider.clear();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                MyNavigation.back(context);

                                final compressedImage =
                                    await imagePickerProvider.compressImage(
                                        imagePickerProvider.selectedImage!);

                                if (compressedImage != null &&
                                    textController.text.isEmpty) {
                                  await chatProvider.handleImageMessage(
                                    authProvider,
                                    compressedImage,
                                  );

                                  imagePickerProvider.clear();
                                } else {
                                  await chatProvider.handleImageWithTextMessage(
                                    authProvider,
                                    compressedImage!,
                                    textController.text.trim(),
                                  );
                                  await service.sendNotificationToUsers(
                                    title: authProvider.currentUser!.username,
                                    content: "sent an image "
                                        " ${textController.text.trim()}",
                                  );
                                  imagePickerProvider.clear();
                                }
                              },
                              child: const Text('Send'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      debugPrint("No image selected.");
                    }
                  },
                  customMessageBuilder: (message, {required messageWidth}) {
                    return CustomMessageWidget(
                      messageData: message.metadata ?? {},
                      messageWidth: 1.sw,
                    );
                  },
                  messages: messages,
                  // Use messages from ValueNotifier
                  onSendPressed: (message) async {
                    if (internetProvider.connectionStatus ==
                            AppStatus.kDisconnected ||
                        internetProvider.connectionStatus ==
                            AppStatus.kDisconnected) {
                      ToastHelper.showErrorToast(
                        context: context,
                        message: "Please check your internet connection",
                      );
                      return;
                    }

                    final url = extractFirstUrl(message.text);

                    print("$url------------------------");

                    final metaModel = MetaModel(
                      img: null,
                      url: url,
                      text: message.text,
                    );

                    final newMessage = ChatMessage(
                      id: Uuid().v4(),
                      author: types.User(
                        id: authProvider.uid,
                        firstName: authProvider.currentUser?.username,
                      ),
                      metaModel: metaModel,
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                    );

                    print(
                        "STORE TO LOCAL STORAGE IS CALLED -----------------------");

                    // Add message to ValueNotifier instead of localMessages
                    final chatMessage =
                        CustomMapper.mapCustomMessageModalToChatMessage(
                      userId: authProvider.uid,
                      newMessage,
                    );

                    _addMessageToNotifier(chatMessage);

                    chatProvider.sendMessage(newMessage);
                    shareIntentProvider.clear();
                    _clearController();
                    shareContentProvider.clear();
                    imagePickerProvider.clear();
                  },
                  user: types.User(
                    firstName: authProvider.currentUser?.username,
                    id: authProvider.uid,
                  ),
                  showUserNames: true,
                  showUserAvatars: true,
                  customBottomWidget: authProvider.currentUser?.canPost ?? false
                      ? null
                      : const SizedBox.shrink(),
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
                    padding: EdgeInsets.all(16),
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                            SizedBox(width: 16),
                            Text(
                              "${(progress * 100).toStringAsFixed(0)}% uploaded",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 16),
                            IconButton(
                              icon: Icon(Icons.cancel, color: Colors.red),
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
