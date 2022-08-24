import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:provider/provider.dart';

import '../item_model.dart';
import '../item_widget.dart';
import 'edit_tools/edit_tools_widget.dart';
import 'paint_model.dart';

class PaintItemWidget extends StatelessWidget {
  const PaintItemWidget({
    super.key,
    this.onDelete,
    this.operationState = OperationState.editing,
    this.onPointerDown,
  });

  final void Function()? onDelete;

  final void Function()? onPointerDown;

  final OperationState? operationState;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaintItem(),
      child: _ItemWidget(
        onPointerDown: onPointerDown,
        onDelete: onDelete,
        operationState: operationState,
      ),
    );
  }
}

class _ItemWidget extends StatelessWidget {
  const _ItemWidget({
    required this.onPointerDown,
    required this.onDelete,
    required this.operationState,
  });

  final void Function()? onPointerDown;
  final void Function()? onDelete;
  final OperationState? operationState;

  @override
  Widget build(BuildContext context) {
    final paintModel = context.read<PaintItem>();

    return ItemWidget(
      isCentered: false,
      isEditable: true,
      onPointerDown: onPointerDown,
      tapToEdit: paintModel.tapToEdit,
      editTools: EditToolsWidget(paintModel: paintModel),
      operationState: operationState,
      onDelete: onDelete,
      onOperationStateChanged: paintModel.onOperationStateChanged,
      onFlipped: (newFlipMatrix) {
        paintModel.flipMatrix = newFlipMatrix;
        return true;
      },
      child: FittedBox(
        child: SizedBox.fromSize(
          size: PaintItem.size,
          child: Stack(
            children: const [
              _DrawingBoardWidget(),
              _EditMask(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawingBoardWidget extends StatelessWidget {
  const _DrawingBoardWidget();

  @override
  Widget build(BuildContext context) {
    PaintItem paintModel = context.watch<PaintItem>();

    return Transform(
      transform: paintModel.flipMatrix,
      alignment: Alignment.center,
      child: DrawingBoard(
        controller: paintModel.drawingController,
        background: paintModel.child,
      ),
    );
  }
}

class _EditMask extends StatelessWidget {
  const _EditMask();

  @override
  Widget build(BuildContext context) {
    PaintItem? paintModel;
    final isEditing = context.select((PaintItem model) {
      paintModel ??= model;
      return model.isEditing;
    });

    return isEditing
        ? const SizedBox.shrink()
        : const Positioned.fill(
            child: ColoredBox(color: Colors.transparent),
          );
  }
}
