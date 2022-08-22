import 'package:flutter/material.dart';

class CaseStyle {
  const CaseStyle({
    this.borderColor = Colors.white,
    this.borderWidth = 1,
    this.iconColor,
    this.iconSize = 24,
  });

  /// 边框(包括操作手柄)颜色
  final Color borderColor;

  /// 边框粗细
  final double borderWidth;

  /// 图标颜色
  final Color? iconColor;

  /// 图标大小
  final double iconSize;
}

enum OperationState {
  /// 正在编辑
  editing,

  /// 正在移动
  moving,

  /// 正在缩放
  scaling,

  /// 正在旋转
  rotating,

  /// 常规状态
  idle,

  /// 编辑完成
  complete,
}

/// 自定义对象
@immutable
class StackBoardItem {
  const StackBoardItem({
    required this.child,
    this.id,
    this.onDelete,
    this.caseStyle,
    this.tapToEdit = false,
  });

  /// item id
  final int? id;

  /// 子控件
  final Widget child;

  /// 移除回调
  final Future<bool> Function()? onDelete;

  /// 外框样式
  final CaseStyle? caseStyle;

  /// 点击进行编辑
  final bool tapToEdit;

  /// 对象拷贝
  StackBoardItem copyWith({
    int? id,
    Widget? child,
    Future<bool> Function()? onDelete,
    CaseStyle? caseStyle,
    bool? tapToEdit,
  }) =>
      StackBoardItem(
        id: id ?? this.id,
        child: child ?? this.child,
        onDelete: onDelete ?? this.onDelete,
        caseStyle: caseStyle ?? this.caseStyle,
        tapToEdit: tapToEdit ?? this.tapToEdit,
      );

  /// 对象比较
  bool sameWith(StackBoardItem item) => item.id == id;

  @override
  bool operator ==(Object other) => other is StackBoardItem && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
