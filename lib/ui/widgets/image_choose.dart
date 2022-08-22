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
