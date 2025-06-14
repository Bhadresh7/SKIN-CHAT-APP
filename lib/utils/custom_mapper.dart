import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:skin_chat_app/models/chat_message.dart';
import 'package:uuid/uuid.dart';

class CustomMapper {
  static List<types.CustomMessage> getCustomMessage(
      List<ChatMessage> messages) {
    // Sort messages by createdAt in ascending order (oldest to newest)
    messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final convMessages = messages
        .map((message) => mapCustomMessageModalToChatMessage(
              message,
              userId: message.author.id,
            ))
        .toList();

    return convMessages;
  }

  static types.CustomMessage mapCustomMessageModalToChatMessage(
    ChatMessage chatModel, {
    required String userId,
  }) {
    print("YYYYYY${chatModel.author.firstName}");
    return types.CustomMessage(
      author: types.User(id: userId, firstName: chatModel.author.firstName),
      id: Uuid().v4(),
      metadata: {
        'text': chatModel.metaModel.text,
        'url': chatModel.metaModel.url,
        'img': chatModel.metaModel.img,
      },
      createdAt: chatModel.createdAt,
    );
  }
}
