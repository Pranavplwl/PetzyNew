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
    apiKey: 'AIzaSyDDyx78Za3rrgqCCZGQR8K4mFY36oimXSo',
    appId: '1:154989115518:web:49af2bb065db7620b1802f',
    messagingSenderId: '154989115518',
    projectId: 'petzy-8b4c0',
    authDomain: 'petzy-8b4c0.firebaseapp.com',
    storageBucket: 'petzy-8b4c0.firebasestorage.app',
    measurementId: 'G-L8BP1N9J9D',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBpmf65G-JwE92seLKhZVk_cqMDpaaqnmg',
    appId: '1:154989115518:android:508872f3146b98ecb1802f',
    messagingSenderId: '154989115518',
    projectId: 'petzy-8b4c0',
    storageBucket: 'petzy-8b4c0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBKE5s6OTMm7fYrCTYMqpYKo6YEogjLIBU',
    appId: '1:154989115518:ios:816fc65bfcecf518b1802f',
    messagingSenderId: '154989115518',
    projectId: 'petzy-8b4c0',
    storageBucket: 'petzy-8b4c0.firebasestorage.app',
    iosBundleId: 'com.example.petzy',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBKE5s6OTMm7fYrCTYMqpYKo6YEogjLIBU',
    appId: '1:154989115518:ios:816fc65bfcecf518b1802f',
    messagingSenderId: '154989115518',
    projectId: 'petzy-8b4c0',
    storageBucket: 'petzy-8b4c0.firebasestorage.app',
    iosBundleId: 'com.example.petzy',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDDyx78Za3rrgqCCZGQR8K4mFY36oimXSo',
    appId: '1:154989115518:web:c9f3d8251fe4d8edb1802f',
    messagingSenderId: '154989115518',
    projectId: 'petzy-8b4c0',
    authDomain: 'petzy-8b4c0.firebaseapp.com',
    storageBucket: 'petzy-8b4c0.firebasestorage.app',
    measurementId: 'G-FDGERF10HC',
  );
}
