import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../image_model.dart';
import 'mask_picker_model.dart';

// Expanded(
//   child: ElevatedButton.icon(
//     onPressed: () => imageModel.maskSvgString = null,
//     icon: const Icon(Icons.not_interested_rounded),
//     label: const Text('None'),
//   ),
// ),

class MaskPickerWidget extends StatelessWidget {
  const MaskPickerWidget({
    super.key,
    required this.imageModel,
    required this.currentMask,
  });

  final ImageItem imageModel;
  final String? currentMask;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MaskPicker(imageModel, currentMask),
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 4,
        child: _MasksGridWidget(imageModel),
      ),
    );
  }
}

class _MasksGridWidget extends StatelessWidget {
  const _MasksGridWidget(this.imageModel);

  final ImageItem imageModel;

  @override
  Widget build(BuildContext context) {
    MaskPicker? maskPickerModel;
    final masks = context.select((MaskPicker model) {
      maskPickerModel ??= model;
      return model.masks;
    });

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      ),
      itemCount: masks.length,
      itemBuilder: (context, index) {
        return _MaskWidget(
          imageModel: imageModel,
          masks: masks,
          index: index,
        );
      },
    );
  }
}

class _MaskWidget extends StatelessWidget {
  const _MaskWidget({
    required this.imageModel,
    required this.masks,
    required this.index,
  });

  final ImageItem imageModel;
  final List<String> masks;
  final int index;

  @override
  Widget build(BuildContext context) {
    MaskPicker? maskPickerModel;
    final selectedIndex = context.select((MaskPicker model) {
      maskPickerModel ??= model;
      return model.selectedIndex;
    });

    return Card(
      elevation: 8,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        onTap: () {
          index == 0
              ? imageModel.maskSvgString = null
              : imageModel.maskSvgString = masks[index];
          maskPickerModel?.selectedIndex = index;
        },
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: index == 0
                ? Icon(
                    Icons.not_interested_rounded,
                    color: index == selectedIndex ? Colors.blue : null,
                  )
                : SvgPicture.string(
                    generateMaskSVG(maskPickerModel!.masks[index]),
                    color: index == selectedIndex
                        ? Colors.blue
                        : IconTheme.of(context).color,
                  ),
          ),
        ),
      ),
    );
  }
}
