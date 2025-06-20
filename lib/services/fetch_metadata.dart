import 'package:flutter/cupertino.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:skin_chat_app/models/preview_data_model.dart';

class FetchMeta {
  PreviewDataModel? previewDataModal;

  Future<PreviewDataModel?> fetchLinkMetadata(String url) async {
    try {
      final metadata = await MetadataFetch.extract(url);
      previewDataModal = PreviewDataModel(
        title: metadata?.title ?? "",
        description: metadata?.description ?? "",
        image: metadata?.image ?? "",
        url: metadata?.url ?? "",
      );

      return previewDataModal;
    } catch (e) {
      debugPrint("Metadata fetch error: $e");
    }
    return null;
  }
}
