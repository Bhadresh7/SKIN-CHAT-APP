import 'package:flutter/material.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:receive_intent/receive_intent.dart' as receive_intent;

class SharedContentProvider with ChangeNotifier {
  String? _receivedText;
  String? _receivedImagePath;
  Metadata? _linkMetadata;
  bool _isLoadingMetadata = false;

  String? get receivedText => _receivedText;

  String? get receivedImagePath => _receivedImagePath;

  Metadata? get linkMetadata => _linkMetadata;

  bool get isLoadingMetadata => _isLoadingMetadata;

  String? _imageMetadata;

  String? get imageMetadata => _imageMetadata;

  SharedContentProvider() {
    _initIntentHandling();
  }

  void _initIntentHandling() {
    receive_intent.ReceiveIntent.receivedIntentStream.listen(_handleIntent);
    receive_intent.ReceiveIntent.getInitialIntent().then(_handleIntent);
  }

  // void _handleIntent(receive_intent.Intent? intent) {
  //   if (intent == null) return;
  //
  //   final extras = intent.extra ?? {};
  //   final sharedText = extras['android.intent.extra.TEXT']?.toString();
  //   final sharedStream = extras['android.intent.extra.STREAM'];
  //
  //   if (sharedText != null) {
  //     _receivedText = sharedText.trim();
  //   }
  //
  //   if (sharedStream != null) {
  //     if (sharedStream is String) {
  //       _receivedImagePath = sharedStream;
  //     } else if (sharedStream is List) {
  //       _receivedImagePath =
  //           sharedStream.isNotEmpty ? sharedStream[0].toString() : null;
  //     } else {
  //       debugPrint("Unknown stream type: ${sharedStream.runtimeType}");
  //     }
  //   }
  //
  //   notifyListeners();
  //
  //   if (_receivedText != null && _isValidUrl(_receivedText!)) {
  //     fetchLinkMetadata(_receivedText!);
  //   }
  // }

  void _handleIntent(receive_intent.Intent? intent) {
    if (intent == null) return;

    _imageMetadata = intent.extra?['android.intent.extra.TEXT']?.toString();
    print("SHARED TEXT FORM APPS ))))>>>>>$_imageMetadata");
    // final sharedImage =
    //     intent.extra?['android.intent.extra.STREAM']?.toString();
    // final sharedImages =
    // intent.extra?['android.intent.extra.STREAM'] as List<dynamic>?;

    // if (sharedImage != null) {
    //   _receivedImagePath = sharedImage;
    //   print(sharedImage);
    // } else if (sharedImages != null && sharedImages.isNotEmpty) {
    //   _receivedImagePath = sharedImages[0].toString();
    //   print(sharedImages[0].toString());
    // }

    notifyListeners();

    if (_receivedText != null && _isValidUrl(_receivedText!)) {
      fetchLinkMetadata(_receivedText!);
    }
  }

  bool _isValidUrl(String text) {
    try {
      final uri = Uri.parse(text);
      return uri.hasScheme && uri.hasAuthority;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchLinkMetadata(String url) async {
    _isLoadingMetadata = true;
    notifyListeners();

    try {
      final metadata = await MetadataFetch.extract(url);
      _linkMetadata = metadata;
    } catch (e) {
      debugPrint("Metadata fetch error: $e");
    } finally {
      _isLoadingMetadata = false;
      notifyListeners();
    }
  }

  bool isImageLink(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith(".jpg") ||
        lower.endsWith(".jpeg") ||
        lower.endsWith(".png") ||
        lower.endsWith(".gif") ||
        lower.endsWith(".webp");
  }

  void clear() {
    _receivedText = null;
    _receivedImagePath = null;
    _linkMetadata = null;
    _isLoadingMetadata = false;
    notifyListeners();
  }
}

// import 'package:flutter/material.dart';
// import 'package:metadata_fetch/metadata_fetch.dart';
// import 'package:receive_intent/receive_intent.dart' as receive_intent;
//
// class SharedContentProvider with ChangeNotifier {
//   Metadata? _linkMetadata;
//   bool _isLoadingMetadata = false;
//   MetaData? _imgMetadata;
//
//   Metadata? get linkMetadata => _linkMetadata;
//
//   MetaData? get imgMetadata => _imgMetadata;
//
//   bool get isLoadingMetadata => _isLoadingMetadata;
//
//   SharedContentProvider() {
//     _initIntentHandling();
//   }
//
//   void _initIntentHandling() {
//     // Listen for intents when the app is already running
//     receive_intent.ReceiveIntent.receivedIntentStream.listen(_handleIntent);
//
//     // Handle intent when the app is started with a shared intent
//     receive_intent.ReceiveIntent.getInitialIntent().then(_handleIntent);
//   }
//
//   // Handle the incoming intent and extract metadata from the shared URL
//   void _handleIntent(receive_intent.Intent? intent) {
//     if (intent == null) return;
//
//     final sharedText = intent.extra?['android.intent.extra.TEXT']?.toString();
//     if (sharedText != null && _isValidUrl(sharedText)) {
//       print("Received URL: $sharedText"); // Print the received URL
//       fetchLinkMetadata(sharedText);
//     }
//   }
//
//   // Check if the shared content is a valid URL
//   bool _isValidUrl(String text) {
//     try {
//       final uri = Uri.parse(text);
//       return uri.hasScheme && uri.hasAuthority;
//     } catch (_) {
//       return false;
//     }
//   }
//
//   // Fetch metadata for the URL
//   Future<void> fetchLinkMetadata(String url) async {
//     _isLoadingMetadata = true;
//     notifyListeners();
//
//     try {
//       print(
//           "Fetching metadata for URL: $url"); // Print before fetching metadata
//       final metadata = await MetadataFetch.extract(url);
//
//       print("==========================");
//       print(metadata?.description);
//       print(metadata?.title);
//       print(metadata?.url);
//       print(metadata?.image);
//       print("===========================");
//
//       _linkMetadata = metadata;
//
//       print("Metadata fetched: $metadata"); // Print the fetched metadata
//     } catch (e) {
//       debugPrint("Metadata fetch error: $e");
//     } finally {
//       _isLoadingMetadata = false;
//       notifyListeners();
//     }
//   }
//
//   void clear() {
//     _linkMetadata = null;
//     _isLoadingMetadata = false;
//     notifyListeners();
//   }
// }
