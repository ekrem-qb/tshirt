import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';

import '../item_model.dart';

class PaintItem extends Item with ChangeNotifier {
  PaintItem({
    super.id,
    super.onDelete,
  }) : super(
          child: const SizedBox(width: 260, height: 260),
        );

  @override
  PaintItem copyWith({
    int? id,
    Widget? child,
    Function(bool)? onEdit,
    Future<bool> Function()? onDelete,
  }) {
    return PaintItem(
      id: id ?? this.id,
      onDelete: onDelete ?? this.onDelete,
    );
  }

  static const size = Size(260, 260);

  DrawingController drawingController =
      DrawingController(config: DrawConfig.def());

  bool _isEditing = true;
  bool get isEditing => _isEditing;
  set isEditing(bool isEditing) {
    _isEditing = isEditing;
    notifyListeners();
  }

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
    }

    return true;
  }

  @override
  void dispose() {
    drawingController.dispose();
    super.dispose();
  }
}
