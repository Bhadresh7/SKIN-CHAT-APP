class PreviewDataModal {
  final String title;
  final String description;
  final String image;
  final String url;

  PreviewDataModal({
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

  factory PreviewDataModal.fromJson(Map<String, dynamic> json) {
    return PreviewDataModal(
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
