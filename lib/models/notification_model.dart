class NotificationModel {
  NotificationModel({
    required this.uid,
    required this.title,
    required this.content,
  });

  final String uid;
  final String title;
  final String content;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'title': title,
      'content': content,
    };
  }
}
