import 'package:flutter/cupertino.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:skin_chat_app/modal/preview_data_modal.dart';

class FetchMeta {
  PreviewDataModal? previewDataModal;

  Future<PreviewDataModal?> fetchLinkMetadata(String url) async {
    try {
      final metadata = await MetadataFetch.extract(url);
      previewDataModal = PreviewDataModal(
        title: metadata?.title ?? "",
        description: metadata?.description ?? "",
        image: metadata?.image ?? "",
        url: metadata?.url ?? "",
      );
      print(previewDataModal.toString());

      return previewDataModal;
    } catch (e) {
      debugPrint("Metadata fetch error: $e");
    }
    return null;
  }
}
