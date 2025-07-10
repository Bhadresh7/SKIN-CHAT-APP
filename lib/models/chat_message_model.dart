import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:hive/hive.dart';
import 'package:skin_chat_app/models/meta_model.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 2)
class ChatMessageModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final Map<String, dynamic> authorJson;

  @HiveField(2)
  final MetaModel metaModel;

  @HiveField(3)
  final int createdAt;

  ChatMessageModel({
    required this.id,
    required types.User author,
    required this.metaModel,
    required this.createdAt,
  }) : authorJson = author.toJson();

  types.User get author => types.User.fromJson(authorJson);

  /// Create from a Flutter Chat `CustomMessage`
  factory ChatMessageModel.fromCustomMessage(types.CustomMessage msg) {
    return ChatMessageModel(
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
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      author: types.User.fromJson(json['author'] as Map<String, dynamic>),
      metaModel:
          MetaModel.fromJson(json['metadata'] as Map<String, dynamic>? ?? {}),
      createdAt:
          json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  String toString() {
    return 'ChatMessageModel{id: $id, authorJson: $authorJson, metaModel: $metaModel, createdAt: $createdAt}';
  }
}
