import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:hive/hive.dart';
import 'package:skin_chat_app/models/meta_model.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 2)
class ChatMessage extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final Map<String, dynamic> authorJson;

  @HiveField(2)
  final MetaModel metaModel;

  @HiveField(3)
  final int createdAt;

  ChatMessage({
    required this.id,
    required types.User author,
    required this.metaModel,
    required this.createdAt,
  }) : authorJson = author.toJson();

  types.User get author => types.User.fromJson(authorJson);

  /// Create from a Flutter Chat `CustomMessage`
  factory ChatMessage.fromCustomMessage(types.CustomMessage msg) {
    return ChatMessage(
      id: msg.id,
      author: msg.author,
      metaModel: MetaModel.fromJson(msg.metadata ?? {}),
      createdAt: msg.createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Convert to JSON for storage or debug
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': authorJson,
      'metadata': metaModel.toJson(),
      'createdAt': createdAt,
    };
  }

  /// Load from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      author: types.User.fromJson(json['author'] as Map<String, dynamic>),
      metaModel:
          MetaModel.fromJson(json['metadata'] as Map<String, dynamic>? ?? {}),
      createdAt:
          json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}
