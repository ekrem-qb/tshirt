import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../stack_board.dart';

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
      create: (context) => MaskedImage(image),
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
  final ImageProvider<Object> image;
  final void Function()? onDelete;
  final OperationState? operationState;
  final CaseStyle? caseStyle;

  @override
  Widget build(BuildContext context) {
    MaskedImage? maskedImage;
    final ImageShader? maskShader = context.select((MaskedImage model) {
      maskedImage ??= model;
      return model.maskShader;
    });

    return ItemCase(
      isEditable: true,
      onPointerDown: onPointerDown,
      tapToEdit: maskedImage!.tapToEdit,
      onDelete: onDelete,
      onSizeChanged: maskedImage!.onSizeChanged,
      onResizeDone: maskedImage!.onResizeDone,
      onOperationStateChanged: (OperationState operationState) {
        if (operationState == OperationState.editing) {
          maskedImage!.onEdit();
        }
        return true;
      },
      operationState: operationState,
      caseStyle: caseStyle,
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
    final image = context.select((MaskedImage model) => model.image);

    return Image(
      image: image,
      width: MaskedImage.defaultSize.width,
      height: MaskedImage.defaultSize.height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      loadingBuilder: (
        BuildContext context,
        Widget child,
        ImageChunkEvent? loadingProgress,
      ) {
        return loadingProgress != null
            ? Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!,
                ),
              )
            : child;
      },
    );
  }
}
