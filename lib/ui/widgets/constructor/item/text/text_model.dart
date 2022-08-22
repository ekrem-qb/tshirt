import 'package:flutter/material.dart';

import '../item_model.dart';
import '../item_widget.dart';

class TextItem extends Item with ChangeNotifier {
  TextItem(
    this.text, {
    super.id,
    super.onDelete,
    super.caseStyle,
    bool? tapToEdit,
  }) : super(
          child: const SizedBox.shrink(),
          tapToEdit: tapToEdit ?? false,
        );

  @override
  TextItem copyWith({
    String? text,
    int? id,
    Widget? child,
    Future<bool> Function()? onDelete,
    CaseStyle? caseStyle,
    bool? tapToEdit,
  }) {
    return TextItem(
      text ?? this.text,
      id: id ?? this.id,
      onDelete: onDelete ?? this.onDelete,
      caseStyle: caseStyle ?? this.caseStyle,
      tapToEdit: tapToEdit ?? this.tapToEdit,
    );
  }

  String text;

  TextStyle style = const TextStyle();

  TextAlign textAlign = TextAlign.center;

  bool _isEditing = false;

  bool get isEditing => _isEditing;

  set isEditing(bool newIsEditing) {
    if (_isEditing != newIsEditing) {
      _isEditing = newIsEditing;
      notifyListeners();
    }
  }

  final FocusNode focusNode = FocusNode();

  Size? oldSize;

  final ItemController itemController = ItemController();

  Matrix4 _flipMatrix = Matrix4.identity();

  Matrix4 get flipMatrix => _flipMatrix;

  set flipMatrix(Matrix4 flipMatrix) {
    _flipMatrix = flipMatrix;
    notifyListeners();
  }

  bool? onOperationStateChanged(OperationState newOperationState) {
    if (newOperationState != OperationState.editing && isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => isEditing = false);
    } else if (newOperationState == OperationState.editing && !isEditing) {
      isEditing = true;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => focusNode.requestFocus());
    }

    return true;
  }

  void onTextChanged(String newText) {
    text = newText;
    calculateTextOffset();
    notifyListeners();
  }

  Size calculateTextSize() {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  Offset calculateTextOffset() {
    final Size newSize = calculateTextSize();

    final Offset scaleOffset = Offset(
        newSize.width - (oldSize?.width ?? newSize.width),
        newSize.height - (oldSize?.height ?? newSize.height));

    oldSize = newSize;

    itemController.resizeCase(scaleOffset);

    return scaleOffset;
  }

  @override
  void dispose() {
    focusNode.dispose();
    itemController.dispose();
    super.dispose();
  }
}
