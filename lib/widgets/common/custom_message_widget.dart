import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:skin_chat_app/helpers/save_image_helper.dart';
import 'package:skin_chat_app/models/preview_data_model.dart';
import 'package:skin_chat_app/services/fetch_metadata.dart';
import 'package:url_launcher/url_launcher.dart';

import 'clikable_text_widget.dart';
import 'image_shimmer.dart';

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
  final ValueNotifier<File?> _imageNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _loadImageFile();
  }

  Future<void> _loadImageFile() async {
    final imageUrl = widget.messageData['img']?.toString();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final file = await SaveImageHelper.saveImageToGallery(url: imageUrl);
      _imageNotifier.value = file;
    }
  }

  Future<PreviewDataModel?> _getMetadata(String? url) async {
    if (url == null || url.isEmpty) return null;

    if (_metadataCache.containsKey(url)) {
      return _metadataCache[url];
    }

    final metadata = await FetchMeta().fetchLinkMetadata(url);
    print("METADATA =====================");
    print(metadata?.toJson());
    if (metadata != null) {
      _metadataCache[url] = metadata;
    }

    return metadata;
  }

  @override
  void dispose() {
    _imageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.messageData['text']?.toString();
    final url = widget.messageData['url']?.toString();
    final previewDataMap = widget.messageData['previewData'];

    PreviewDataModel? previewDataModel;
    if (previewDataMap is Map<String, dynamic>) {
      previewDataModel = PreviewDataModel.fromJson(previewDataMap);
    }

    if ((text == null || text.isEmpty) &&
        (widget.messageData['img'] == null ||
            widget.messageData['img'].toString().isEmpty) &&
        (url == null || url.isEmpty)) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<PreviewDataModel?>(
      future: previewDataModel != null
          ? Future.value(previewDataModel)
          : _getMetadata(url),
      builder: (context, snapshot) {
        final metadata = snapshot.data;

        Widget content = Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (metadata != null) ...[
                if (metadata.image.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: metadata.image,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const ImageShimmer(),
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
              ValueListenableBuilder<File?>(
                valueListenable: _imageNotifier,
                builder: (context, file, _) {
                  if (file == null) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GestureDetector(
                        onTap: () {
                          showImageViewer(
                            context,
                            FileImage(file),
                            useSafeArea: true,
                            swipeDismissible: true,
                            doubleTapZoomable: true,
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.file(
                              file,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              ClickableTextWidget(
                url: url,
                text: text,
              ),
            ],
          ),
        );

        if (metadata != null && url != null && url.isNotEmpty) {
          return InkWell(
            onTap: () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: content,
          );
        }

        return content;
      },
    );
  }
}
