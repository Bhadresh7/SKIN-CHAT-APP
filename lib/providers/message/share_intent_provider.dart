import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';

class ShareIntentProvider extends ChangeNotifier {
  StreamSubscription<List<SharedFile>>? _sharingIntentSubscription;
  List<SharedFile>? sharedFiles;

  List<String> sharedValues = [];

  ShareIntentProvider() {
    _initializeSharingIntent();
  }

  void _initializeSharingIntent() {
    // Listen for shared files when the app is active
    _sharingIntentSubscription = FlutterSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedFile> files) {
      _updateSharedFiles(files);
    }, onError: (err) {
      debugPrint("Error in getMediaStream: $err");
    });

    // Fetch initial shared files if the app starts from a sharing intent
    FlutterSharingIntent.instance.getInitialSharing().then((files) {
      _updateSharedFiles(files);
    }).catchError((err) {
      debugPrint("Error in getInitialSharing: $err");
    });
  }

  void _updateSharedFiles(List<SharedFile> files) {
    List<String> newSharedValues =
        files.map((file) => file.value ?? "").toList();

    if (sharedValues != newSharedValues) {
      sharedFiles = files;
      sharedValues = newSharedValues;
      print("🔥🔥🔥$sharedValues");
      debugPrint("FROM PROVIDER=========>${sharedValues[0]}");
      print(sharedValues);
      notifyListeners();
    }
  }

  void clear() {
    sharedFiles = null;
    sharedValues = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _sharingIntentSubscription?.cancel();
    super.dispose();
  }
}
