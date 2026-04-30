import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
        return ios;
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
    apiKey: 'AIzaSyC8v73P2-_AxVKlyalzeG7GlNj3J05o9xw',
    appId: '1:393237392419:web:c16f4c91ddb95c762f9596',
    messagingSenderId: '393237392419',
    projectId: 'reservaloya-2a59c',
    authDomain: 'reservaloya-2a59c.firebaseapp.com',
    storageBucket: 'reservaloya-2a59c.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCMGyISWZP8DkzoRgSrYWN-CMZtSGMbllM',
    appId: '1:393237392419:android:be6a921e9e69deff2f9596',
    messagingSenderId: '393237392419',
    projectId: 'reservaloya-2a59c',
    storageBucket: 'reservaloya-2a59c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDDi7qeIUII920Ct35_XGpsqB1OCcFcL6s',
    appId: '1:393237392419:ios:c16f4c91ddb95c762f9596',
    messagingSenderId: '393237392419',
    projectId: 'reservaloya-2a59c',
    storageBucket: 'reservaloya-2a59c.firebasestorage.app',
    iosBundleId: 'cl.reservaloyareservaloyaAdmin',
  );
}
