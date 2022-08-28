import 'package:flutter/material.dart';

import '../../../../library/modal_sheet.dart';
import '../image_model.dart';
import 'filter_picker/filter_picker_widget.dart';
import 'mask_picker/mask_picker_widget.dart';

class EditToolsWidget extends StatelessWidget {
  const EditToolsWidget(this.imageModel, {super.key});

  final ImageItem imageModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => imageModel.chooseImage(context),
          child: const Text('Image'),
        ),
        ElevatedButton(
          onPressed: () => showModal(
            context: context,
            child: MaskPickerWidget(
                imageModel: imageModel, currentMask: imageModel.maskSvgString),
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
