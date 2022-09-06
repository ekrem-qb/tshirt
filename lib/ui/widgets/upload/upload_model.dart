import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class Upload extends ChangeNotifier {
  Upload() {
    _startServer();
  }

  ImageProvider? _image;
  ImageProvider? get image => _image;
  set image(ImageProvider? newImage) {
    _image = newImage;
    notifyListeners();
  }

  late final StreamSubscription _subscription;
  late final Process _process;

  void _startServer() async {
    await _closeServer();
    _process = await Process.start('tshirt-print-upload', [], runInShell: true);
    _subscription = _process.stdout.listen((event) async {
      image = FileImage(File(utf8.decode(event).trim()));
    });
  }

  Future<void> _closeServer() async {
    await Process.run('taskkill /f /t /im node.exe', [], runInShell: true);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _process.kill();
    _closeServer();
    super.dispose();
  }
}
