import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../item_model.dart';
import '../item_widget.dart';
import 'edit_tools/edit_tools_widget.dart';
import 'image_model.dart';

class ImageItemWidget extends StatelessWidget {
  const ImageItemWidget({
    super.key,
    required this.image,
    this.onDelete,
    this.onPointerDown,
    this.operationState,
  });

  final ImageProvider image;
  final void Function()? onDelete;
  final void Function()? onPointerDown;
  final OperationState? operationState;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ImageItem(image)..calculateImageSize(),
      child: _ItemWidget(
        image: image,
        onPointerDown: onPointerDown,
        onDelete: onDelete,
        operationState: operationState,
      ),
    );
  }
}

class _ItemWidget extends StatelessWidget {
  const _ItemWidget({
    required this.image,
    required this.onPointerDown,
    required this.onDelete,
    required this.operationState,
  });

  final void Function()? onPointerDown;
  final ImageProvider image;
  final void Function()? onDelete;
  final OperationState? operationState;

  @override
  Widget build(BuildContext context) {
    ImageItem? imageModel;
    final maskShader = context.select((ImageItem model) {
      imageModel ??= model;
      return model.maskShader;
    });

    return ItemWidget(
      controller: imageModel!.itemController,
      isEditable: true,
      onPointerDown: onPointerDown,
      tapToEdit: imageModel!.tapToEdit,
      onDelete: onDelete,
      onSizeChanged: imageModel!.onSizeChanged,
      onResizeDone: imageModel!.onResizeDone,
      onFlipped: (newFlipMatrix) {
        imageModel!.flipMatrix = newFlipMatrix;
        return true;
      },
      operationState: operationState,
      editTools: EditToolsWidget(imageModel!),
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
    // final flipMatrix = context.select((ImageItem model) => model.flipMatrix);
    final ImageItem imageModel = context.watch<ImageItem>();

    if (imageModel.imageSize != null) {
      return Transform(
        transform: imageModel.flipMatrix,
        alignment: Alignment.center,
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix(imageModel.filter),
          child: Image(
            image: imageModel.image,
            width: imageModel.imageSize!.width,
            height: imageModel.imageSize!.height,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
        ),
      );
    } else {
      return SizedBox(
        width: ImageItem.defaultSize.width,
        height: ImageItem.defaultSize.height,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
