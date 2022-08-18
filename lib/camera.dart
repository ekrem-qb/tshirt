import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<CameraController> _initializeControllerFuture() async {
  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  // To display the current output from the Camera,
  // create a CameraController.
  final controller = CameraController(
    // Get a specific camera from the list of available cameras.
    firstCamera,
    // Define the resolution to use.
    ResolutionPreset.max,
  );

  // Next, initialize the controller. This returns a Future.+
  await controller.initialize();

  return controller;
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({Key? key}) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  final Future<CameraController> _controllerFuture =
      _initializeControllerFuture();
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    if (_controller != null) {
      if (_controller!.value.isInitialized) {
        _controller?.dispose();
      }
    }
    _controllerFuture
        .then((initializedController) => _controller = initializedController);
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<CameraController>(
        future: _controllerFuture,
        builder: (context, snapshot) {
          final CameraController? controller = snapshot.data;
          if (controller != null) {
            // If the Future is complete, display the preview.
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(pi),
              child: CameraPreview(controller),
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {
          final image = await _controller?.takePicture();
          if (image != null) {
            // Take the Picture in a try / catch block. If anything goes wrong,
            // catch the error.
            try {
              // Attempt to take a picture and get the file `image`
              // where it was saved.

              // If the picture was taken, display it on a new screen.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DisplayPictureScreen(
                    // Pass the automatically generated path to
                    // the DisplayPictureScreen widget.
                    imagePath: image.path,
                  ),
                ),
              );
            } catch (e) {
              // If an error occurs, log the error to the console.
              print(e);
            }
          }
        },
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  late final imageNoBgPath;
  late final result;

  DisplayPictureScreen({Key? key, required this.imagePath}) : super(key: key) {
    imageNoBgPath = imagePath.replaceFirst('.jpeg', '_no_bg.png');
    result = Process.run(
        'py -m carvekit -i $imagePath -o $imageNoBgPath --device cpu --post none',
        [],
        runInShell: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Column(
        children: [
          Image.file(File(imagePath)),
          Expanded(
            child: FutureBuilder<ProcessResult>(
              future: result,
              builder: ((context, snapshot) {
                return snapshot.hasData
                    ? Column(
                        children: [
                          Image.file(File(imageNoBgPath)),
                          Text(snapshot.data?.stderr),
                        ],
                      )
                    : const Center(child: CircularProgressIndicator());
              }),
            ),
          )
        ],
      ),
    );
  }
}
