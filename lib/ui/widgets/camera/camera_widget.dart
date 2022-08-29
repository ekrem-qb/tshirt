import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'camera_model.dart';

class CameraWidget extends StatelessWidget {
  const CameraWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: ChangeNotifierProvider(
        create: (context) => Camera(),
        child: const _CameraSwitchWidget(),
      ),
    );
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

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          ColoredBox(
            color: Colors.black,
            child: Center(
              child: isInitialized
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(pi),
                      child: CameraPreview(cameraModel!.controller),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
          Positioned(
            height: MediaQuery.of(context).size.height / 7.5,
            left: 0,
            right: 0,
            bottom: 0,
            child: Material(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 1,
                      child: FittedBox(
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: FittedBox(
                        child: IconButton(
                          onPressed:
                              isInitialized ? cameraModel!.takePicture : null,
                          icon: const Icon(Icons.camera_alt_rounded),
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: SizedBox(),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          ColoredBox(
            color: Colors.black,
            child: Center(
              child: useCutOutImage
                  ? imageCutOut != null
                      ? Image(image: imageCutOut)
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            Image(image: image!),
                            const Center(child: CircularProgressIndicator()),
                          ],
                        )
                  : Image(
                      image: image!,
                    ),
            ),
          ),
          Positioned(
            height: MediaQuery.of(context).size.height / 7.5,
            left: 0,
            right: 0,
            bottom: 0,
            child: Material(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 1,
                      child: FittedBox(
                        child: IconButton(
                          onPressed: cameraModel!.resetImage,
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: FittedBox(
                        child: IconButton(
                          onPressed: () => cameraModel!.useCutOutImage =
                              !cameraModel!.useCutOutImage,
                          icon: Icon(useCutOutImage
                              ? Icons.auto_fix_off_rounded
                              : Icons.auto_fix_high_rounded),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: FittedBox(
                        child: IconButton(
                          onPressed: useCutOutImage
                              ? imageCutOut != null
                                  ? () => Navigator.pop<FileImage>(
                                      context, imageCutOut)
                                  : null
                              : () => Navigator.pop<FileImage>(context, image!),
                          icon: const Icon(Icons.done_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
