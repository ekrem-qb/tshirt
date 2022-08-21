import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/widgets.dart';

extension ImageTool on ImageProvider {
  Future<Uint8List?> getBytes(
      {ImageByteFormat format = ImageByteFormat.png}) async {
    final ImageStream imageStream = resolve(ImageConfiguration.empty);
    final Completer<Uint8List?> completer = Completer<Uint8List?>();
    final ImageStreamListener listener = ImageStreamListener(
      (ImageInfo imageInfo, bool synchronousCall) async {
        final ByteData? bytes =
            await imageInfo.image.toByteData(format: format);
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

  Future<ImageInfo> getImageInfo() async {
    final ImageStream imageStream = resolve(ImageConfiguration.empty);
    final Completer<ImageInfo> completer = Completer<ImageInfo>();
    final ImageStreamListener listener = ImageStreamListener(
      (ImageInfo imageInfo, bool synchronousCall) {
        if (!completer.isCompleted) {
          completer.complete(imageInfo);
        }
      },
    );
    imageStream.addListener(listener);
    final ImageInfo image = await completer.future;
    imageStream.removeListener(listener);
    return image;
  }
}
