import 'package:hive/hive.dart';

part 'preview_data_model.g.dart';

@HiveType(typeId: 3)
class PreviewDataModel extends HiveObject {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String description;
  @HiveField(2)
  final String image;
  @HiveField(3)
  final String url;

  PreviewDataModel({
    required this.title,
    required this.description,
    required this.image,
    required this.url,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image': image,
      'url': url,
    };
  }

  factory PreviewDataModel.fromJson(Map<String, dynamic> json) {
    return PreviewDataModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      url: json['url'] ?? '',
    );
  }

  @override
  String toString() {
    return 'PreviewDataModal{title: $title, description: $description, image: $image, url: $url}';
  }
}
