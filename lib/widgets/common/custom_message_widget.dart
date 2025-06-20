import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:skin_chat_app/helpers/save_image_helper.dart';
import 'package:skin_chat_app/models/preview_data_model.dart';
import 'package:skin_chat_app/services/fetch_metadata.dart';
import 'package:skin_chat_app/widgets/common/clikable_text_widget.dart';
import 'package:skin_chat_app/widgets/common/image_shimmer.dart';

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

class _CustomMessageWidgetState extends State<CustomMessageWidget> {
  static final Map<String, PreviewDataModel> _metadataCache = {};

  Future<PreviewDataModel?>? _metadataFuture;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    print(
        "Custom message Widget is called ------------------------------------------");
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

  Future<PreviewDataModel?> getMeta(String url) async {
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
    final previewDataMap = widget.messageData['previewData'];
    PreviewDataModel? previewDataModel;
    if (previewDataMap is Map<String, dynamic>) {
      previewDataModel = PreviewDataModel.fromJson(previewDataMap);
    }

    if ((text == null || text.isEmpty) &&
        (imageUrl == null || imageUrl.isEmpty) &&
        (url == null || url.isEmpty)) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<PreviewDataModel?>(
      future: _metadataFuture,
      builder: (context, snapshot) {
        final metadata = previewDataModel;

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
                if (metadata.image.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          showImageViewer(
                            context,
                            CachedNetworkImageProvider(metadata.image),
                            swipeDismissible: true,
                            useSafeArea: true,
                            doubleTapZoomable: true,
                          );
                        } catch (e) {
                          print('Error downloading image: $e');
                        }
                      },
                      child: CachedNetworkImage(
                        imageUrl: metadata.image,
                        fit: BoxFit.fitWidth,
                        placeholder: (context, url) =>
                            const Center(child: ImageShimmer()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image),
                      ),
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
                if (metadata.description.isNotEmpty)
                  Text(metadata.description.toString()),
              ],
              if (imageUrl != null && imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          final file = await SaveImageHelper.saveImageToGallery(
                            url: imageUrl,
                          );
                          showImageViewer(
                            context,
                            FileImage(file),
                            useSafeArea: true,
                            swipeDismissible: true,
                            doubleTapZoomable: true,
                          );
                        } catch (e) {
                          print('Error downloading image: $e');
                        }
                      },
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.fitWidth,
                        placeholder: (context, url) =>
                            const Center(child: ImageShimmer()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),
              ClickableTextWidget(
                url: url,
                text: text,
              ),
            ],
          ),
        );
      },
    );
  }
}
