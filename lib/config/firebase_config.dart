import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) return android;
    if (defaultTargetPlatform == TargetPlatform.iOS) return ios;
    return web;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBsplpeXg1-WyO4MtbFNqS6pEUzJ0lh_DA',
    appId: '1:954465770137:android:2a4cdea761beb090bd3608',
    messagingSenderId: '954465770137',
    projectId: 'yad-video-editor',
    storageBucket: 'yad-video-editor.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBsplpeXg1-WyO4MtbFNqS6pEUzJ0lh_DA',
    appId: '1:954465770137:ios:2a4cdea761beb090bd3608',
    messagingSenderId: '954465770137',
    projectId: 'yad-video-editor',
    storageBucket: 'yad-video-editor.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBsplpeXg1-WyO4MtbFNqS6pEUzJ0lh_DA',
    appId: '1:954465770137:web:2a4cdea761beb090bd3608',
    messagingSenderId: '954465770137',
    projectId: 'yad-video-editor',
    authDomain: 'yad-video-editor.firebaseapp.com',
    storageBucket: 'yad-video-editor.firebasestorage.app',
  );
}
