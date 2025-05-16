import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class LinkPreviewWidget extends StatelessWidget {
  final types.TextMessage message;

  const LinkPreviewWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final previewData = message.previewData;
    if (previewData == null) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (previewData.image != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              previewData.image!.toString(),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        if (previewData.title != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              previewData.title!,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        if (previewData.description != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              previewData.description!,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            message.text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
