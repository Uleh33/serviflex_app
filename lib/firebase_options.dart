// ignore_for_file: lines_longer_than_80_chars, avoid_classes_on_declarations
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCl5Q2YH_nkjGqBZMLABbiy2eBMhfQ0qZY',
    appId: '1:494243542565:web:cdd79d13074bdaa73271cc',
    messagingSenderId: '494243542565',
    projectId: 'device-streaming-4067edcc',
    authDomain: 'device-streaming-4067edcc.firebaseapp.com',
    storageBucket: 'device-streaming-4067edcc.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCl5Q2YH_nkjGqBZMLABbiy2eBMhfQ0qZY',
    appId: '1:494243542565:android:cdd79d13074bdaa73271cc',
    messagingSenderId: '494243542565',
    projectId: 'device-streaming-4067edcc',
    storageBucket: 'device-streaming-4067edcc.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCl5Q2YH_nkjGqBZMLABbiy2eBMhfQ0qZY',
    appId: '1:494243542565:ios:cdd79d13074bdaa73271cc',
    messagingSenderId: '494243542565',
    projectId: 'device-streaming-4067edcc',
    storageBucket: 'device-streaming-4067edcc.appspot.com',
    iosBundleId: 'com.todolisto.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCl5Q2YH_nkjGqBZMLABbiy2eBMhfQ0qZY',
    appId: '1:494243542565:ios:cdd79d13074bdaa73271cc',
    messagingSenderId: '494243542565',
    projectId: 'device-streaming-4067edcc',
    storageBucket: 'device-streaming-4067edcc.appspot.com',
    iosBundleId: 'com.todolisto.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCl5Q2YH_nkjGqBZMLABbiy2eBMhfQ0qZY',
    appId: '1:494243542565:web:cdd79d13074bdaa73271cc',
    messagingSenderId: '494243542565',
    projectId: 'device-streaming-4067edcc',
    authDomain: 'device-streaming-4067edcc.firebaseapp.com',
    storageBucket: 'device-streaming-4067edcc.appspot.com',
  );
}
