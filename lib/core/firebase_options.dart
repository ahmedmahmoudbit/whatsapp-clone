import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
            'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB37aSzQwR_RJatCxy9F7V5hcxSvy1pWqc',
    appId: '1:867907366273:android:03f3e5c37621ae01cf0c80',
    messagingSenderId: '867907366273',
    projectId: 'whatsapp-backend-c4d7f',
    storageBucket: 'whatsapp-backend-c4d7f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBSDWRP0gJNvfu50pTKYfUqRDDEkQsQrUI',
    appId: '1:867907366273:ios:6f8cdf10bb49ba7ecf0c80',
    messagingSenderId: '867907366273',
    projectId: 'whatsapp-backend-c4d7f',
    storageBucket: 'whatsapp-backend-c4d7f.appspot.com',
    iosClientId: '867907366273-j9hk7oisbdk70t3q3ri6n5qveuj30ohh.apps.googleusercontent.com',
    iosBundleId: 'com.example.whatsappUi',
  );
}
