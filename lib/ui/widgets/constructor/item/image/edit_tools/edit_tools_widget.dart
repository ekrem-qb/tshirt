import 'package:flutter/material.dart';

import '../../../../library/modal_sheet.dart';
import '../image_model.dart';
import 'filter_picker/filter_picker_widget.dart';
import 'image_picker/image_picker_widget.dart';
import 'mask_picker/mask_picker_widget.dart';

class EditToolsWidget extends StatelessWidget {
  const EditToolsWidget(this.imageModel, {super.key});

  final ImageItem imageModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () async {
            final result = await showModal<ImageProvider>(
              context: context,
              dimBackground: true,
              child: const ImagePickerWidget(),
            );
            if (result != null) {
              imageModel.image = result;
            }
          },
          child: const Text('Image'),
        ),
        ElevatedButton(
          onPressed: () => showModal(
            context: context,
            child: MaskPickerWidget(
                imageModel: imageModel, currentMask: imageModel.mask),
          ),
          child: const Text('Mask'),
        ),
        ElevatedButton(
          onPressed: () => showModal(
            context: context,
            child: FilterPickerWidget(imageModel),
          ),
          child: const Text('Filter'),
        ),
      ],
    );
  }
}
