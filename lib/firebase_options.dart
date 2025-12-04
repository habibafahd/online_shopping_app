// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Web configuration
      return FirebaseOptions(
        apiKey: "AIzaSyAMj4hBG08a2_OIR6dWtII22GOXmZKIW-8",
        authDomain: "online-shopping-app-7595d.firebaseapp.com",
        projectId: "online-shopping-app-7595d",
        storageBucket: "online-shopping-app-7595d.appspot.com",
        messagingSenderId: "561760250720",
        appId: "1:561760250720:web:70ddf91960f1c808fa8c05",
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: "YOUR_ANDROID_API_KEY",
          appId: "YOUR_ANDROID_APP_ID",
          messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
          projectId: "online-shopping-app-7595d",
          storageBucket: "online-shopping-app-7595d.appspot.com",
        );
      case TargetPlatform.iOS:
        return FirebaseOptions(
          apiKey: "YOUR_IOS_API_KEY",
          appId: "YOUR_IOS_APP_ID",
          messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
          projectId: "online-shopping-app-7595d",
          storageBucket: "online-shopping-app-7595d.appspot.com",
          iosBundleId: "YOUR_IOS_BUNDLE_ID",
        );
      default:
        throw UnsupportedError("This platform is not supported.");
    }
  }
}
