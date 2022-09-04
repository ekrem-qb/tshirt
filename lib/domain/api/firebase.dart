import 'dart:async';

import 'package:firebase_dart/firebase_dart.dart';
import 'package:firebase_dart/implementation/pure_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:platform_info/platform_info.dart' as platform_info;
import 'package:url_launcher/url_launcher.dart';
import 'package:hive/hive.dart';

late final FirebaseApp _firebaseApp;
late final DatabaseReference db;
late final FirebaseStorage storage;

Future<void> setupFirebase() async {
  await _setup();
  _firebaseApp = await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: 'AIzaSyCi5ReavEzaAnN5mkjURUVeqim40G6--tY',
        authDomain: 't-shirt-bb053.firebaseapp.com',
        projectId: 't-shirt-bb053',
        storageBucket: 't-shirt-bb053.appspot.com',
        messagingSenderId: '610570154668',
        appId: '1:610570154668:web:88822592c41d743d11e509',
        measurementId: 'G-TJD5R3G6TB',
        databaseURL:
            'https://t-shirt-bb053-default-rtdb.europe-west1.firebasedatabase.app/'),
  );

  final database = FirebaseDatabase(app: _firebaseApp);
  await database.setPersistenceEnabled(true);
  db = database.reference();

  storage = FirebaseStorage.instanceFor(app: _firebaseApp);
}

const _channel = MethodChannel('firebase_dart_flutter');

Future<void> _setup({
  bool isolated = !kIsWeb,
}) async {
  isolated = isolated && !kIsWeb;
  WidgetsFlutterBinding.ensureInitialized();

  String? path;
  if (!kIsWeb) {
    final appDir = await getApplicationSupportDirectory();
    path = appDir.path;
    if (isolated) {
      Hive.init(path);
    }
  }

  FirebaseDart.setup(
    storagePath: path,
    isolated: isolated,
    launchUrl: kIsWeb
        ? null
        : (url, {bool popup = false}) async {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          },
    platform: await _getPlatform(),
  );
}

Future<Platform> _getPlatform() async {
  final p = platform_info.Platform.instance;

  if (kIsWeb) {
    return Platform.web(
      currentUrl: Uri.base.toString(),
      isMobile: p.isMobile,
      isOnline: true,
    );
  }

  switch (p.operatingSystem) {
    case platform_info.OperatingSystem.android:
      final i = await PackageInfo.fromPlatform();
      return Platform.android(
        isOnline: true,
        packageId: i.packageName,
        sha1Cert: await _channel.invokeMethod('getSha1Cert'),
      );
    case platform_info.OperatingSystem.iOS:
      final i = await PackageInfo.fromPlatform();
      return Platform.ios(
        isOnline: true,
        appId: i.packageName,
      );
    case platform_info.OperatingSystem.macOS:
      final i = await PackageInfo.fromPlatform();
      return Platform.macos(
        isOnline: true,
        appId: i.packageName,
      );
    case platform_info.OperatingSystem.linux:
      return Platform.linux(
        isOnline: true,
      );
    case platform_info.OperatingSystem.windows:
      return Platform.windows(
        isOnline: true,
      );
    default:
      throw UnsupportedError('Unsupported platform ${p.operatingSystem}');
  }
}
