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
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCQZrEf2EFHjepRzipU8BFkeq4RY2BHv_w',
    appId: '1:544300406240:web:50f52e440dccc6a161c785',
    messagingSenderId: '544300406240',
    projectId: 'lotchat-app',
    authDomain: 'lotchat-app.firebaseapp.com',
    storageBucket: 'lotchat-app.firebasestorage.app',
    measurementId: 'G-5949N8Q3T7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCoeTaILUD3larRmgDg-SzTopBnQcRODCg',
    appId: '1:544300406240:android:59da6c8e33a7fc3461c785',
    messagingSenderId: '544300406240',
    projectId: 'lotchat-app',
    storageBucket: 'lotchat-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDZp-FC6xfFzimor7TdXT7CLa4YmkSPieM',
    appId: '1:544300406240:ios:59e7bfdb449a7ab461c785',
    messagingSenderId: '544300406240',
    projectId: 'lotchat-app',
    storageBucket: 'lotchat-app.firebasestorage.app',
    iosBundleId: 'com.example.lotchatApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDZp-FC6xfFzimor7TdXT7CLa4YmkSPieM',
    appId: '1:544300406240:ios:59e7bfdb449a7ab461c785',
    messagingSenderId: '544300406240',
    projectId: 'lotchat-app',
    storageBucket: 'lotchat-app.firebasestorage.app',
    iosBundleId: 'com.example.lotchatApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCQZrEf2EFHjepRzipU8BFkeq4RY2BHv_w',
    appId: '1:544300406240:web:566a89c94318af0561c785',
    messagingSenderId: '544300406240',
    projectId: 'lotchat-app',
    authDomain: 'lotchat-app.firebaseapp.com',
    storageBucket: 'lotchat-app.firebasestorage.app',
    measurementId: 'G-EW0ZNH06KG',
  );

}