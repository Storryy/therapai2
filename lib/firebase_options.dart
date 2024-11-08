// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyD1isKVA3DehS1bdKipdc9hMFNQWbASJSc',
    appId: '1:441931590091:web:8a7e92c22c13ed89d76e4e',
    messagingSenderId: '441931590091',
    projectId: 'therapai-c3ccd',
    authDomain: 'therapai-c3ccd.firebaseapp.com',
    storageBucket: 'therapai-c3ccd.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAiS2o2U1hmMnbWDHmFIjjWwMy1G_I_5us',
    appId: '1:441931590091:android:9dffb4ab0f52e061d76e4e',
    messagingSenderId: '441931590091',
    projectId: 'therapai-c3ccd',
    storageBucket: 'therapai-c3ccd.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCcT4bYLXYWx3xZUiSM6FUigSSrjrEcI9U',
    appId: '1:441931590091:ios:1ac0ff6a55e22f27d76e4e',
    messagingSenderId: '441931590091',
    projectId: 'therapai-c3ccd',
    storageBucket: 'therapai-c3ccd.appspot.com',
    iosBundleId: 'com.example.therapai2.therapai2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCcT4bYLXYWx3xZUiSM6FUigSSrjrEcI9U',
    appId: '1:441931590091:ios:1ac0ff6a55e22f27d76e4e',
    messagingSenderId: '441931590091',
    projectId: 'therapai-c3ccd',
    storageBucket: 'therapai-c3ccd.appspot.com',
    iosBundleId: 'com.example.therapai2.therapai2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD1isKVA3DehS1bdKipdc9hMFNQWbASJSc',
    appId: '1:441931590091:web:d5ec4eed699cc794d76e4e',
    messagingSenderId: '441931590091',
    projectId: 'therapai-c3ccd',
    authDomain: 'therapai-c3ccd.firebaseapp.com',
    storageBucket: 'therapai-c3ccd.appspot.com',
  );
}
