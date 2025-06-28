import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:skin_chat_app/models/chat_message.dart';
import 'package:skin_chat_app/models/meta_model.dart';
import 'package:skin_chat_app/models/preview_data_model.dart';

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
    return types.CustomMessage(
      author: types.User(id: userId, firstName: chatModel.author.firstName),
      id: chatModel.id,
      metadata: {
        'text': chatModel.metaModel.text,
        'url': chatModel.metaModel.url,
        'img': chatModel.metaModel.img,
        'previewData': chatModel.metaModel.previewDataModel?.toJson(),
      },
      createdAt: chatModel.createdAt,
    );
  }

  static ChatMessage mapCustomToChatMessage(types.CustomMessage customMsg) {
    return ChatMessage(
      id: customMsg.id,
      createdAt: customMsg.createdAt ?? DateTime.now().millisecondsSinceEpoch,
      author: types.User(
          id: customMsg.author.id, firstName: customMsg.author.firstName),
      metaModel: MetaModel(
        text: customMsg.metadata?['text'],
        url: customMsg.metadata?['url'],
        img: customMsg.metadata?['img'],
        previewDataModel: PreviewDataModel.fromJson(
          customMsg.metadata?['previewData'] ?? {},
        ),
      ),
    );
  }
}
