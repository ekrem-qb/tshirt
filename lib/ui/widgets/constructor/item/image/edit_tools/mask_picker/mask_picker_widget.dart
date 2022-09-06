import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../../../../domain/entity/mask.dart';
import '../../../../../../theme.dart';
import '../../image_model.dart';
import 'mask_picker_model.dart';

class MaskPickerWidget extends StatelessWidget {
  const MaskPickerWidget({
    super.key,
    required this.imageModel,
    required this.currentMask,
  });

  final ImageItem imageModel;
  final Mask? currentMask;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MaskPicker(imageModel, currentMask),
      child: SizedBox(
        height: modalSheetHeight * 3,
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
    final maskPickerModel = context.watch<MaskPicker>();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      ),
      itemCount:
          !maskPickerModel.isLoading ? maskPickerModel.masks.length : null,
      itemBuilder: (context, index) {
        return _MaskWidget(
          imageModel: imageModel,
          index: index,
        );
      },
    );
  }
}

class _MaskWidget extends StatelessWidget {
  const _MaskWidget({
    required this.imageModel,
    required this.index,
  });

  final ImageItem imageModel;
  final int index;

  @override
  Widget build(BuildContext context) {
    MaskPicker? maskPickerModel;
    final selectedMaskId = context.select((MaskPicker model) {
      maskPickerModel ??= model;
      return model.selectedMaskId;
    });
    final String? id = index < maskPickerModel!.masks.length
        ? maskPickerModel!.masks.values.elementAt(index).id
        : null;

    return Card(
      elevation: 8,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        onTap: id == null
            ? null
            : () {
                id == '' || maskPickerModel!.masks[id]!.svg == ''
                    ? imageModel.mask = null
                    : imageModel.mask = maskPickerModel!.masks[id]!;
                maskPickerModel?.selectedMaskId = id;
              },
        child: id == null
            ? Center(
                heightFactor: 0.25,
                child: CircularProgressIndicator(
                  color: IconTheme.of(context).color,
                ),
              )
            : FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: id == '' || maskPickerModel!.masks[id]!.svg == ''
                      ? Icon(
                          Icons.not_interested_rounded,
                          color: id == selectedMaskId ? Colors.blue : null,
                        )
                      : SvgPicture.string(
                          generateMaskSVG(maskPickerModel!.masks[id]!.svg),
                          color: id == selectedMaskId
                              ? Colors.blue
                              : IconTheme.of(context).color,
                        ),
                ),
              ),
      ),
    );
  }
}
