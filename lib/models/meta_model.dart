import 'package:hive/hive.dart';

part 'meta_model.g.dart';

@HiveType(typeId: 1)
class MetaModel extends HiveObject {
  @HiveField(0)
  String? text;

  @HiveField(1)
  String? url;

  @HiveField(2)
  String? img;

  MetaModel({this.text, this.url, this.img});

  factory MetaModel.fromJson(Map<String, dynamic> json) {
    return MetaModel(
      text: json['text'] as String?,
      url: json['url'] as String?,
      img: json['img'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'url': url,
      'img': img,
    };
  }
}
