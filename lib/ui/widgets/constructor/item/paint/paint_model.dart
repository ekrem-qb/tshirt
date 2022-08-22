import 'package:flutter/material.dart';

import '../item_model.dart';

/// 画板
class PaintItem extends Item {
  const PaintItem({
    this.size = const Size(260, 260),
    Widget background = const SizedBox(width: 260, height: 260),
    super.id,
    super.onDelete,
    super.caseStyle,
    bool? tapToEdit,
  }) : super(
          child: background,
          tapToEdit: tapToEdit ?? false,
        );

  /// 画布初始大小
  final Size size;

  @override
  PaintItem copyWith({
    int? id,
    Widget? child,
    Function(bool)? onEdit,
    Future<bool> Function()? onDelete,
    CaseStyle? caseStyle,
    Size? size,
    bool? tapToEdit,
  }) {
    return PaintItem(
      background: child ?? this.child,
      id: id ?? this.id,
      onDelete: onDelete ?? this.onDelete,
      caseStyle: caseStyle ?? this.caseStyle,
      size: size ?? this.size,
      tapToEdit: tapToEdit ?? this.tapToEdit,
    );
  }
}
