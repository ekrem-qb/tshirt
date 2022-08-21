import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Widget imageChooseWidget(context) {
  return Center(
    child: ElevatedButton.icon(
      onPressed: () => _pickupImage(context),
      icon: const Icon(Icons.file_open_rounded),
      label: const Text('File'),
    ),
  );
}

void _pickupImage(BuildContext context) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
  );
  if (result != null) {
    final file = File(result.files.single.path!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pop(context, FileImage(file));
    });
  }
}

Widget maskChooseWidget(context) {
  return Center(
    child: ElevatedButton.icon(
      onPressed: () => _pickSvgString(context),
      icon: const Icon(Icons.file_open_rounded),
      label: const Text('File'),
    ),
  );
}

void _pickSvgString(BuildContext context) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: <String>['svg'],
  );
  late final String? maskSvgString;
  if (result != null) {
    final File file = File(result.files.single.path!);
    maskSvgString = await file.readAsString();
  } else {
    maskSvgString = null;
  }
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.pop(context, maskSvgString);
  });
}
