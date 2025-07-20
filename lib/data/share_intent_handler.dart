import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_handler/share_handler.dart';

/// A service to handle incoming share intents (images, files, text) using share_handler.
class ShareIntentHandler with ChangeNotifier {
  SharedMedia? _sharedMedia;
  StreamSubscription<SharedMedia?>? _subscription;

  SharedMedia? get sharedMedia => _sharedMedia;

  /// Call this in your app's initState or main() to start listening for share intents.
  void startListening() {
    _subscription = ShareHandlerPlatform.instance.sharedMediaStream.listen((media) {
      _sharedMedia = media;
      notifyListeners();
    });
    // Also check for initial share (when app is launched from a share intent)
    ShareHandlerPlatform.instance.getInitialSharedMedia().then((media) {
      if (media != null) {
        _sharedMedia = media;
        notifyListeners();
      }
    });
  }

  /// Call this to clear the current shared media after handling it.
  void clearSharedMedia() {
    _sharedMedia = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
} 