import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../item_model.dart';
import '../item_widget.dart';
import 'edit_tools/edit_tools_widget.dart';
import 'text_model.dart';

class TextItemWidget extends StatelessWidget {
  const TextItemWidget({
    super.key,
    required this.text,
    this.onDelete,
    this.onPointerDown,
    this.operationState,
  });

  final String text;
  final void Function()? onDelete;
  final void Function()? onPointerDown;
  final OperationState? operationState;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TextItem(text)..calculateTextOffset(),
      child: _ItemWidget(
        text: text,
        onPointerDown: onPointerDown,
        onDelete: onDelete,
        operationState: operationState,
      ),
    );
  }
}

class _ItemWidget extends StatelessWidget {
  const _ItemWidget({
    required this.text,
    required this.onPointerDown,
    required this.onDelete,
    required this.operationState,
  });

  final String text;
  final void Function()? onPointerDown;
  final void Function()? onDelete;
  final OperationState? operationState;

  @override
  Widget build(BuildContext context) {
    final TextItem textModel = context.read<TextItem>();

    return ItemWidget(
      controller: textModel.itemController,
      isCentered: false,
      isEditable: true,
      onPointerDown: onPointerDown,
      tapToEdit: textModel.tapToEdit,
      onDelete: onDelete,
      operationState: operationState,
      onOperationStateChanged: textModel.onOperationStateChanged,
      onFlipped: (newFlipMatrix) {
        textModel.flipMatrix = newFlipMatrix;
        return true;
      },
      editTools: TextEditToolsWidget(textModel: textModel),
      child: const _TextWidget(),
    );
  }
}

class _TextWidget extends StatelessWidget {
  const _TextWidget();

  @override
  Widget build(BuildContext context) {
    final textModel = context.watch<TextItem>();

    return FittedBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          width: textModel.calculateTextSize().width + 32,
          child: Transform(
            transform: textModel.flipMatrix,
            alignment: Alignment.center,
            child: TextFormField(
              enabled: textModel.isEditing,
              focusNode: textModel.focusNode,
              decoration: const InputDecoration(border: InputBorder.none),
              initialValue: textModel.text,
              onChanged: textModel.onTextChanged,
              style: textModel.style,
              textAlign: textModel.textAlign,
              maxLines: null,
            ),
          ),
        ),
      ),
    );
  }
}
