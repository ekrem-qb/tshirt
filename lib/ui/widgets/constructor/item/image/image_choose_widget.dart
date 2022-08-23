import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Widget imageChooseWidget(context) {
  return Padding(
    padding: const EdgeInsets.all(64),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => _pickupImage(context),
          icon: const Icon(Icons.file_open_rounded),
          label: const Text('File'),
        ),
      ],
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
