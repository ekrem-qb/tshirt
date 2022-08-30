import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../../theme.dart';
import '../../../../../camera/camera_widget.dart';
import '../../../../../library/modal_sheet.dart';

class ImagePickerWidget extends StatelessWidget {
  const ImagePickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(buttonsSpacing),
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 10,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickupImage(context),
                icon: const Icon(Icons.file_open_rounded),
                label: const Text('File'),
              ),
            ),
            const SizedBox(width: buttonsSpacing),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _takePicture(context),
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text('Camera'),
              ),
            ),
          ],
        ),
      ),
    );
  }
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

void _takePicture(BuildContext context) async {
  final result = await showModal<FileImage>(
    context: context,
    child: const CameraWidget(),
  );
  Navigator.pop(context, result);
}
