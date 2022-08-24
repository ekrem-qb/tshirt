import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'camera_model.dart';

class CameraWidget extends StatelessWidget {
  const CameraWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Camera(),
      child: const _CameraSwitchWidget(),
    );

    // floatingActionButton: FloatingActionButton(
    //   child: const Icon(Icons.camera_alt),
    //   // Provide an onPressed callback.
    //   onPressed: () async {
    //     final image = await _controller?.takePicture();
    //     if (image != null) {
    //       // Take the Picture in a try / catch block. If anything goes wrong,
    //       // catch the error.
    //       try {
    //         // Attempt to take a picture and get the file `image`
    //         // where it was saved.

    //         // If the picture was taken, display it on a new screen.
    //         Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //             builder: (context) => DisplayPictureScreen(
    //               // Pass the automatically generated path to
    //               // the DisplayPictureScreen widget.
    //               imagePath: image.path,
    //             ),
    //           ),
    //         );
    //       } catch (e) {
    //         // If an error occurs, log the error to the console.
    //         print(e);
    //       }
    //     }
    //   },
    // ),
    // );
  }
}

class _CameraSwitchWidget extends StatelessWidget {
  const _CameraSwitchWidget();

  @override
  Widget build(BuildContext context) {
    final image = context.select((Camera model) => model.image);

    if (image == null) {
      return const _TakePictureWidget();
    } else {
      return const _PreviewWidget();
    }
  }
}

class _TakePictureWidget extends StatelessWidget {
  const _TakePictureWidget();

  @override
  Widget build(BuildContext context) {
    Camera? cameraModel;
    final isInitialized = context.select((Camera model) {
      cameraModel ??= model;
      return model.isInitialized;
    });

    return Column(
      children: [
        isInitialized
            ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(pi),
                child: CameraPreview(cameraModel!.controller),
              )
            : const AspectRatio(
                aspectRatio: 16 / 9,
                child: ColoredBox(
                  color: Colors.black,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
        SizedBox(
          height: 50,
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
            onPressed: cameraModel!.takePicture,
            child: const Icon(Icons.camera_alt_rounded),
          ),
        ),
      ],
    );
  }
}

class _PreviewWidget extends StatelessWidget {
  const _PreviewWidget();

  @override
  Widget build(BuildContext context) {
    Camera? cameraModel;
    final image = context.select((Camera model) {
      cameraModel ??= model;
      return model.image;
    });
    final imageCutOut = context.select((Camera model) => model.imageCutOut);
    final useCutOutImage =
        context.select((Camera model) => model.useCutOutImage);

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: useCutOutImage
              ? imageCutOut != null
                  ? Image(image: imageCutOut)
                  : Stack(
                      children: [
                        Image(image: image!),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    )
              : ColoredBox(
                  color: Colors.black,
                  child: Image(
                    image: image!,
                  ),
                ),
        ),
        SizedBox(
          height: 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: cameraModel!.resetImage,
                  child: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => cameraModel!.useCutOutImage =
                      !cameraModel!.useCutOutImage,
                  child: Icon(useCutOutImage
                      ? Icons.auto_fix_off_rounded
                      : Icons.auto_fix_high_rounded),
                ),
              ),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: useCutOutImage
                      ? imageCutOut != null
                          ? () => Navigator.pop<FileImage>(context, imageCutOut)
                          : null
                      : () => Navigator.pop<FileImage>(context, image!),
                  child: const Icon(Icons.done_rounded),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
