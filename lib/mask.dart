import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class MaskedImage extends StatefulWidget {
  MaskedImage({required this.child, required this.maskImage});

  final Widget? child;
  ImageProvider maskImage;

  @override
  State<MaskedImage> createState() => MaskedImageState();
}

class MaskedImageState extends State<MaskedImage> {
  TypedData? imageData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    imageData = null;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return FutureBuilder<ui.ImageShader>(
        future: _createShaderImage(context, constraints, widget.maskImage),
        builder:
            (BuildContext context, AsyncSnapshot<ui.ImageShader> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }
          return ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (ui.Rect rect) => snapshot.data!,
            child: widget.child,
          );
        },
      );
    });
  }

  Future<ui.ImageShader> _createShaderImage(
    BuildContext context,
    BoxConstraints constraints,
    ImageProvider maskImage,
  ) async {
    imageData ??= await maskImage.getBytes(context) ?? ByteData(0);

    final ui.Codec codec = await ui.instantiateImageCodec(
      imageData!.buffer.asUint8List(),
      targetWidth: constraints.maxWidth.toInt(),
      targetHeight: constraints.maxHeight.toInt(),
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    final ImageShader shader = ImageShader(frameInfo.image, TileMode.decal,
        TileMode.decal, Matrix4.identity().storage);
    return shader;
  }
}

extension ImageTool on ImageProvider {
  Future<Uint8List?> getBytes(BuildContext context,
      {ImageByteFormat format = ImageByteFormat.png}) async {
    final ImageStream imageStream =
        resolve(createLocalImageConfiguration(context));
    final Completer<Uint8List?> completer = Completer<Uint8List?>();
    final ImageStreamListener listener = ImageStreamListener(
      (ImageInfo imageInfo, bool synchronousCall) async {
        final bytes = await imageInfo.image.toByteData(format: format);
        if (!completer.isCompleted) {
          completer.complete(bytes?.buffer.asUint8List());
        }
      },
    );
    imageStream.addListener(listener);
    final Uint8List? imageBytes = await completer.future;
    imageStream.removeListener(listener);
    return imageBytes;
  }
}

class MaskedImageItem extends StatefulWidget {
  const MaskedImageItem({
    Key? key,
  }) : super(key: key);

  @override
  State<MaskedImageItem> createState() => _MaskedImageItemState();
}

class _MaskedImageItemState extends State<MaskedImageItem> {
  ImageProvider maskImage =
      const NetworkImage('https://pngimg.com/uploads/heart/heart_PNG51120.png');
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: GestureDetector(
        onDoubleTap: () async {
          final FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['png'],
          );

          if (result != null) {
            final File file = File(result.files.single.path!);
            maskImage = FileImage(file);
            setState(() {});
          }
        },
        child: MaskedImage(
          maskImage: maskImage,
          child: Image.network(
            'https://uprostim.com/wp-content/uploads/2021/05/image034-5.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
