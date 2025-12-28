// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDu4Kwf5e6uA6P3iuSYbrsCj_glqN-N8Wg',
    appId: '1:463077511300:web:ae94816cba4fcdccc132d1',
    messagingSenderId: '463077511300',
    projectId: 'amar-bari-app-by-rasel',
    authDomain: 'amar-bari-app-by-rasel.firebaseapp.com',
    storageBucket: 'amar-bari-app-by-rasel.firebasestorage.app',
    measurementId: 'G-7TTK5MXFJ9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDQMQaiXie8G-A_v52wooFizvTgIh2j8VM',
    appId: '1:463077511300:android:36c568ca491d8b19c132d1',
    messagingSenderId: '463077511300',
    projectId: 'amar-bari-app-by-rasel',
    storageBucket: 'amar-bari-app-by-rasel.firebasestorage.app',
  );
}
