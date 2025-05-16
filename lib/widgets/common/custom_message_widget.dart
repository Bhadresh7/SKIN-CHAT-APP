import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skin_chat_app/modal/preview_data_modal.dart';
import 'package:skin_chat_app/services/fetch_metadata.dart';
import 'package:skin_chat_app/widgets/common/clikable_text_widget.dart';

class CustomMessageWidget extends StatefulWidget {
  final Map<String, dynamic> messageData;
  final double messageWidth;

  const CustomMessageWidget({
    super.key,
    required this.messageData,
    required this.messageWidth,
  });

  @override
  State<CustomMessageWidget> createState() => _CustomMessageWidgetState();
}

// class _CustomMessageWidgetState extends State<CustomMessageWidget> {
//   static final Map<String, PreviewDataModal> _metadataCache = {};
//
//   Future<PreviewDataModal?>? _metadataFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     final url = widget.messageData['url']?.toString();
//
//     if (url != null && url.isNotEmpty) {
//       if (_metadataCache.containsKey(url)) {
//         _metadataFuture = Future.value(_metadataCache[url]);
//       } else {
//         _metadataFuture = getMeta(url);
//       }
//     } else {
//       _metadataFuture = Future.value(null);
//     }
//   }
//
//   Future<PreviewDataModal?> getMeta(String url) async {
//     final service = FetchMeta();
//     final metadata = await service.fetchLinkMetadata(url);
//     if (metadata != null) {
//       _metadataCache[url] = metadata;
//     }
//     return metadata;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final String? text = widget.messageData['text']?.toString();
//     final String? imageUrl = widget.messageData['img']?.toString();
//     final String? url = widget.messageData['url']?.toString();
//
//     if ((text == null || text.isEmpty) &&
//         (imageUrl == null || imageUrl.isEmpty) &&
//         (url == null || url.isEmpty)) {
//       return const SizedBox.shrink();
//     }
//
//     return FutureBuilder<PreviewDataModal?>(
//       future: _metadataFuture,
//       builder: (context, snapshot) {
//         final metadata = snapshot.data;
//
//         return Container(
//           width: widget.messageWidth,
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (imageUrl != null && imageUrl.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 4),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.network(
//                       imageUrl,
//                       width: widget.messageWidth - 16,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) =>
//                           const Icon(Icons.broken_image),
//                     ),
//                   ),
//                 ),
//               if (text != null && text.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 4),
//                   child: Text(text, style: const TextStyle(fontSize: 16)),
//                 ),
//               if (url != null && url.isNotEmpty)
//                 GestureDetector(
//                   onTap: () {
//                     // TODO: Open URL with url_launcher
//                   },
//                   child: Text(
//                     url,
//                     style: const TextStyle(
//                       color: Colors.blue,
//                       decoration: TextDecoration.underline,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ),
//               if (metadata != null) ...[
//                 const Divider(),
//                 if (metadata.image != null && metadata.image.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 4),
//                     child: Image.network(
//                       metadata.image,
//                       height: 100,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) =>
//                           const Icon(Icons.broken_image),
//                     ),
//                   ),
//                 if (metadata.title != null && metadata.title.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 2),
//                     child: Text(
//                       metadata.title,
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 if (metadata.description != null &&
//                     metadata.description.isNotEmpty)
//                   Text(metadata.description),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

class _CustomMessageWidgetState extends State<CustomMessageWidget> {
  static final Map<String, PreviewDataModal> _metadataCache = {};

  Future<PreviewDataModal?>? _metadataFuture;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    _setupMetadata();
  }

  @override
  void didUpdateWidget(covariant CustomMessageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldUrl = oldWidget.messageData['url']?.toString();
    final newUrl = widget.messageData['url']?.toString();

    if (newUrl != oldUrl) {
      _setupMetadata();
    }
  }

  void _setupMetadata() {
    final url = widget.messageData['url']?.toString();
    _currentUrl = url;

    if (url != null && url.isNotEmpty) {
      if (_metadataCache.containsKey(url)) {
        _metadataFuture = Future.value(_metadataCache[url]);
      } else {
        _metadataFuture = getMeta(url);
      }
    } else {
      _metadataFuture = Future.value(null);
    }

    setState(() {}); // Trigger rebuild to update future
  }

  Future<PreviewDataModal?> getMeta(String url) async {
    final service = FetchMeta();
    final metadata = await service.fetchLinkMetadata(url);
    if (metadata != null) {
      _metadataCache[url] = metadata;
    }
    return metadata;
  }

  @override
  Widget build(BuildContext context) {
    final String? text = widget.messageData['text']?.toString();
    final String? imageUrl = widget.messageData['img']?.toString();
    final String? url = widget.messageData['url']?.toString();

    if ((text == null || text.isEmpty) &&
        (imageUrl == null || imageUrl.isEmpty) &&
        (url == null || url.isEmpty)) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<PreviewDataModal?>(
      future: _metadataFuture,
      builder: (context, snapshot) {
        final metadata = snapshot.data;

        return Container(
          width: widget.messageWidth,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (metadata != null) ...[
                const Divider(),
                if (metadata.image.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: CachedNetworkImage(
                      imageUrl: metadata.image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image),
                    ),
                  ),
                if (metadata.title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      metadata.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                if (metadata.description.isNotEmpty) Text(metadata.description),
              ],
              if (imageUrl != null && imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: widget.messageWidth - 16,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              ClickableTextWidget(
                url: url,
                text: text,
              )
              // if (text != null && text.isNotEmpty)
              //   Padding(
              //     padding: const EdgeInsets.only(bottom: 4),
              //     child: Text(text, style: const TextStyle(fontSize: 16)),
              //   ),
              // if (url != null && url.isNotEmpty)
              //   GestureDetector(
              //     onTap: () {
              //       // TODO: Open URL with url_launcher
              //     },
              //     child: Text(
              //       url,
              //       style: const TextStyle(
              //         color: Colors.blue,
              //         decoration: TextDecoration.underline,
              //         fontSize: 15,
              //       ),
              //     ),
              //   ),
            ],
          ),
        );
      },
    );
  }
}
