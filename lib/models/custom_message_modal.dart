class CustomMessageModal {
  CustomMessageModal({this.text, this.url, this.img});

  String? img;
  String? url;
  String? text;

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'img': img,
      'url': url,
    };
  }
}
