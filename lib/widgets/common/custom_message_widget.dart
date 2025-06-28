import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:skin_chat_app/helpers/save_image_helper.dart';
import 'package:skin_chat_app/models/preview_data_model.dart';
import 'package:skin_chat_app/widgets/common/clikable_text_widget.dart';
import 'package:skin_chat_app/widgets/common/image_shimmer.dart';

import '../../services/fetch_metadata.dart';

class CustomMessageWidget extends StatelessWidget {
  final Map<String, dynamic> messageData;
  final double messageWidth;

  static final Map<String, PreviewDataModel> _metadataCache = {};

  const CustomMessageWidget({
    super.key,
    required this.messageData,
    required this.messageWidth,
  });

  Future<PreviewDataModel?> _getMetadata(String? url) async {
    if (url == null || url.isEmpty) return null;

    if (_metadataCache.containsKey(url)) {
      return _metadataCache[url];
    }

    final service = FetchMeta();
    final metadata = await service.fetchLinkMetadata(url);
    if (metadata != null) {
      _metadataCache[url] = metadata;
    }
    print("FROM CUSTOM WIDGET **********${metadata?.toJson()}");
    return metadata;
  }

  @override
  Widget build(BuildContext context) {
    final String? text = messageData['text']?.toString();
    final String? imageUrl = messageData['img']?.toString();
    final String? url = messageData['url']?.toString();
    final previewDataMap = messageData['previewData'];

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
      future: previewDataModel != null
          ? Future.value(previewDataModel)
          : _getMetadata(url),
      builder: (context, snapshot) {
        final metadata = snapshot.data;

        return Container(
          width: messageWidth,
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
                      onTap: () {
                        showImageViewer(
                          context,
                          CachedNetworkImageProvider(metadata.image),
                          swipeDismissible: true,
                          useSafeArea: true,
                          doubleTapZoomable: true,
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl: metadata.image,
                        fit: BoxFit.fitWidth,
                        placeholder: (_, __) =>
                            const Center(child: ImageShimmer()),
                        errorWidget: (_, __, ___) =>
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
                if (metadata.description.isNotEmpty) Text(metadata.description),
              ],
              if (imageUrl != null && imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GestureDetector(
                      onTap: () async {
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
                      },
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.fitWidth,
                        placeholder: (_, __) =>
                            const Center(child: ImageShimmer()),
                        errorWidget: (_, __, ___) =>
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
