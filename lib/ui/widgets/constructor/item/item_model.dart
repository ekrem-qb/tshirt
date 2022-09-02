import 'package:flutter/material.dart';

class CaseStyle {
  static const Color borderColor = Colors.grey;
  static const double borderWidth = 2;
  static const Color iconColor = Colors.white;
  static const double iconSize = 36;
}

enum OperationState {
  editing,
  moving,
  scaling,
  rotating,
  idle,
  complete,
}

@immutable
class Item {
  const Item({
    required this.child,
    this.id,
    this.onDelete,
    this.tapToEdit = false,
  });

  final int? id;

  final Widget child;

  final Future<bool> Function()? onDelete;

  final bool tapToEdit;

  Item copyWith({
    int? id,
    Widget? child,
    Future<bool> Function()? onDelete,
    bool? tapToEdit,
  }) =>
      Item(
        id: id ?? this.id,
        child: child ?? this.child,
        onDelete: onDelete ?? this.onDelete,
        tapToEdit: tapToEdit ?? this.tapToEdit,
      );

  bool sameWith(Item item) => item.id == id;

  @override
  bool operator ==(Object other) => other is Item && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
