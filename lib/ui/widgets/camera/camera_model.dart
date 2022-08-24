import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class Camera extends ChangeNotifier {
  Camera() {
    _initializeControllerFuture();
  }

  late CameraController controller;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  set isInitialized(bool isInitialized) {
    _isInitialized = isInitialized;
    notifyListeners();
  }

  FileImage? _image;
  FileImage? get image => _image;
  set image(FileImage? image) {
    _image = image;
    notifyListeners();
  }

  FileImage? _imageCutOut;
  FileImage? get imageCutOut => _imageCutOut;
  set imageCutOut(FileImage? imageCutOut) {
    _imageCutOut = imageCutOut;
    notifyListeners();
  }

  bool _useCutOutImage = false;
  bool get useCutOutImage => _useCutOutImage;
  set useCutOutImage(bool useCutOutImage) {
    _useCutOutImage = useCutOutImage;
    notifyListeners();
  }

  int cutOutAttempts = 0;

  Future<void> _initializeControllerFuture() async {
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;

    // To display the current output from the Camera,
    // create a CameraController.
    controller = CameraController(
      // Get a specific camera from the list of available cameras.
      firstCamera,
      // Define the resolution to use.
      ResolutionPreset.max,
    );

    // Next, initialize the controller. This returns a Future.+
    await controller.initialize();

    isInitialized = true;
  }

  Future<void> takePicture() async {
    final file = await controller.takePicture();
    image = FileImage(File(file.path));
    controller.pausePreview();
    cutOutBackground();
  }

  Future<void> cutOutBackground() async {
    if (image != null) {
      final path = image!.file.path.replaceFirst('.jpeg', '_no_bg.png');
      final result = (await Process.run(
        'py -m carvekit -i ${image!.file.path} -o $path --device cpu --post none',
        [],
        runInShell: true,
      ))
          .stderr as String;

      if (result.contains('Removing background: 1')) {
        imageCutOut = FileImage(File(path));
        cutOutAttempts = 0;
      } else if (cutOutAttempts < 3) {
        cutOutAttempts++;
        cutOutBackground();
      }
    }
  }

  void resetImage() {
    image = null;
    imageCutOut = null;
    useCutOutImage = false;
    controller.resumePreview();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
