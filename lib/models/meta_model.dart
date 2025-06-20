import 'package:hive/hive.dart';
import 'package:skin_chat_app/models/preview_data_model.dart';

part 'meta_model.g.dart';

@HiveType(typeId: 1)
class MetaModel extends HiveObject {
  @HiveField(0)
  String? text;

  @HiveField(1)
  String? url;

  @HiveField(2)
  String? img;

  @HiveField(3)
  PreviewDataModel? previewDataModel;

  MetaModel({this.text, this.url, this.img, this.previewDataModel});

  factory MetaModel.fromJson(Map<String, dynamic> json) {
    return MetaModel(
      text: json['text'] as String?,
      url: json['url'] as String?,
      img: json['img'] as String?,
      previewDataModel: json['previewDataModel'] != null
          ? PreviewDataModel.fromJson(json['previewDataModel'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'url': url,
      'img': img,
      'previewDataModal': previewDataModel?.toJson(),
    };
  }
}
