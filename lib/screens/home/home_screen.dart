// // import 'dart:convert';
// // import 'dart:io';
// //
// // import 'package:flutter/material.dart';
// // import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// // import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:skin_chat_app/widgets/common/background_scaffold.dart';
// //
// // class HomeScreen extends StatefulWidget {
// //   const HomeScreen({super.key});
// //
// //   /// routes
// //   // static const String routeName = "/home";
// //
// //   @override
// //   State<HomeScreen> createState() => _HomeScreenState();
// // }
// //
// // class _HomeScreenState extends State<HomeScreen> {
// //   final List<types.Message> _messages = [];
// //   final _user = const types.User(
// //     id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
// //   );
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadMessages();
// //   }
// //
// //   /// Load messages from local storage
// //   Future<void> _loadMessages() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     String? storedMessages = prefs.getString('chat_messages');
// //
// //     if (storedMessages != null) {
// //       List<dynamic> decodedList = jsonDecode(storedMessages);
// //       List<types.Message> loadedMessages = decodedList.map((msg) {
// //         return types.TextMessage.fromJson(msg);
// //       }).toList();
// //
// //       setState(() {
// //         _messages.clear();
// //         _messages.addAll(loadedMessages);
// //       });
// //     }
// //   }
// //
// //   /// Save messages to local storage
// //   Future<void> _saveMessages() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     List<Map<String, dynamic>> messagesJson =
// //         _messages.map((msg) => (msg as types.TextMessage).toJson()).toList();
// //     await prefs.setString('chat_messages', jsonEncode(messagesJson));
// //   }
// //
// //   /// Handle text messages
// //   void _handleSendPressed(types.PartialText message) {
// //     final textMessage = types.TextMessage(
// //       author: _user,
// //       createdAt: DateTime.now().millisecondsSinceEpoch,
// //       id: DateTime.now().millisecondsSinceEpoch.toString(),
// //       text: message.text,
// //     );
// //
// //     _addMessage(textMessage);
// //   }
// //
// //   // /// Handle file selection and upload
// //   // Future<void> _handleFileSelection() async {
// //   //   FilePickerResult? result = await FilePicker.platform.pickFiles();
// //   //
// //   //   if (result != null) {
// //   //     File file = File(result.files.single.path!);
// //   //     String fileName = result.files.single.name;
// //   //     String? extension = result.files.single.extension;
// //   //
// //   //     // Show a preview dialog before sending
// //   //     bool? confirm = await showDialog(
// //   //       context: context,
// //   //       builder: (context) {
// //   //         return AlertDialog(
// //   //           title: Text("File Preview"),
// //   //           content:
// //   //               extension == "jpg" || extension == "png" || extension == "jpeg"
// //   //                   ? Image.file(file) // Show image preview
// //   //                   : Text("Selected File: $fileName"),
// //   //           actions: [
// //   //             TextButton(
// //   //               onPressed: () => Navigator.pop(context, false),
// //   //               child: Text("Cancel"),
// //   //             ),
// //   //             TextButton(
// //   //               onPressed: () => Navigator.pop(context, true),
// //   //               child: Text("Send"),
// //   //             ),
// //   //           ],
// //   //         );
// //   //       },
// //   //     );
// //   //
// //   //     if (confirm == true) {
// //   //       _sendFileMessage(file, fileName);
// //   //     }
// //   //   }
// //   // }
// //   //
// //   // /// Upload File to Firebase Storage
// //   // Future<String> _uploadFile(File file, String fileName) async {
// //   //   String filePath = "chat_files/$fileName";
// //   //   UploadTask uploadTask =
// //   //       FirebaseStorage.instance.ref(filePath).putFile(file);
// //   //
// //   //   TaskSnapshot snapshot = await uploadTask;
// //   //   return await snapshot.ref.getDownloadURL();
// //   // }
// //
// //   /// Send File Message
// //   void _sendFileMessage(File file, String fileName) {
// //     // Create a temporary message with a local URI
// //     final tempMessage = types.FileMessage(
// //       author: _user,
// //       createdAt: DateTime.now().millisecondsSinceEpoch,
// //       id: DateTime.now().millisecondsSinceEpoch.toString(),
// //       mimeType: "application/octet-stream",
// //       name: fileName,
// //       size: file.lengthSync(),
// //       uri: file.path,
// //     );
// //
// //     _addMessage(tempMessage);
// //
// //     // Upload file and replace the message when done
// //     // _uploadFile(file, fileName).then((fileUrl) {
// //     //   final uploadedMessage = tempMessage.copyWith(uri: fileUrl);
// //     //
// //     //   setState(() {
// //     //     int index = _messages.indexWhere((msg) => msg.id == tempMessage.id);
// //     //     if (index != -1) {
// //     //       _messages[index] = uploadedMessage;
// //     //     }
// //     //   });
// //     //
// //     //   _saveMessages();
// //     // });
// //   }
// //
// //   void _addMessage(types.Message message) {
// //     setState(() {
// //       _messages.insert(0, message);
// //     });
// //     _saveMessages();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return PopScope(
// //       canPop: false,
// //       child: BackgroundScaffold(
// //         showDrawer: true,
// //         appBar: AppBar(
// //           actions: [
// //             // IconButton(
// //             //   icon: Icon(Icons.attach_file),
// //             //   onPressed: _handleFileSelection,
// //             // ),
// //           ],
// //         ),
// //         body: Chat(
// //           messages: _messages,
// //           onSendPressed: _handleSendPressed,
// //           user: _user,
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:skin_chat_app/widgets/common/background_scaffold.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<HomeScreen> {
//   String? _role;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserRole();
//   }
//
//   Future<void> _loadUserRole() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _role = prefs.getString('role');
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_role == null) {
//       return const BackgroundScaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return BackgroundScaffold(
//       showDrawer: true,
//       appBar: AppBar(title: Text("Chat - Role: $_role")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('messages')
//             .orderBy('timestamp', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("No messages yet"));
//           }
//
//           final messages = snapshot.data!.docs.map((doc) {
//             final data = doc.data() as Map<String, dynamic>;
//             return types.TextMessage(
//               id: doc.id,
//               author: types.User(id: data['senderId']),
//               createdAt: data['timestamp']?.millisecondsSinceEpoch ?? 0,
//               text: data['text'],
//             );
//           }).toList();
//
//           return Chat(
//             messages: messages,
//             onSendPressed: _handleSendPressed,
//             user: types.User(id: _role == 'admin' ? 'admin_id' : 'user_id'),
//           );
//         },
//       ),
//     );
//   }
//
//   void _handleSendPressed(types.PartialText message) {
//     FirebaseFirestore.instance.collection('messages').add({
//       'text': message.text,
//       'senderId': _role == 'admin' ? 'admin_id' : 'user_id',
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }
// }
