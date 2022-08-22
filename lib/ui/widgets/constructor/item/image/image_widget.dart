import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../item_model.dart';
import '../item_widget.dart';
import 'image_model.dart';

class MaskedImageCase extends StatelessWidget {
  const MaskedImageCase({
    super.key,
    required this.image,
    this.onDelete,
    this.onPointerDown,
    this.operationState,
    this.caseStyle,
  });

  final ImageProvider image;

  final void Function()? onDelete;

  final void Function()? onPointerDown;

  final OperationState? operationState;

  final CaseStyle? caseStyle;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        return MaskedImage(image)..calculateImageSize();
      },
      child: _CaseWidget(
        onPointerDown: onPointerDown,
        image: image,
        onDelete: onDelete,
        operationState: operationState,
        caseStyle: caseStyle,
      ),
    );
  }
}

class _CaseWidget extends StatelessWidget {
  const _CaseWidget({
    required this.onPointerDown,
    required this.image,
    required this.onDelete,
    required this.operationState,
    this.caseStyle,
  });

  final void Function()? onPointerDown;
  final ImageProvider image;
  final void Function()? onDelete;
  final OperationState? operationState;
  final CaseStyle? caseStyle;

  @override
  Widget build(BuildContext context) {
    MaskedImage? maskedImageModel;
    final maskShader = context.select((MaskedImage model) {
      maskedImageModel ??= model;
      return model.maskShader;
    });

    return ItemCase(
      controller: maskedImageModel!.caseController,
      isEditable: true,
      onPointerDown: onPointerDown,
      tapToEdit: maskedImageModel!.tapToEdit,
      onDelete: onDelete,
      onSizeChanged: maskedImageModel!.onSizeChanged,
      onResizeDone: maskedImageModel!.onResizeDone,
      onFlipped: maskedImageModel!.onFlipped,
      operationState: operationState,
      caseStyle: caseStyle,
      editTools: _EditToolsWidget(maskedImageModel!),
      child: maskShader != null
          ? ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (_) => maskShader,
              child: const _ImageWidget(),
            )
          : const _ImageWidget(),
    );
  }
}

class _ImageWidget extends StatelessWidget {
  const _ImageWidget();

  @override
  Widget build(BuildContext context) {
    // Doesn't work, maybe because of Matrix4 comparison
    // final flipMatrix = context.select((MaskedImage model) => model.flipMatrix);
    final MaskedImage maskedImageModel = context.watch<MaskedImage>();

    if (maskedImageModel.imageSize != null) {
      return Transform(
        transform: maskedImageModel.flipMatrix,
        alignment: Alignment.center,
        child: Image(
          image: maskedImageModel.image,
          width: maskedImageModel.imageSize!.width,
          height: maskedImageModel.imageSize!.height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      );
    } else {
      return SizedBox(
        width: MaskedImage.defaultSize.width,
        height: MaskedImage.defaultSize.height,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}

class _EditToolsWidget extends StatelessWidget {
  const _EditToolsWidget(this.maskedImageModel);

  final MaskedImage maskedImageModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => maskedImageModel.chooseImage(context),
          child: const Text('Image'),
        ),
        ElevatedButton(
          onPressed: () => maskedImageModel.chooseMask(context),
          child: const Text('Mask'),
        ),
      ],
    );
  }
}
