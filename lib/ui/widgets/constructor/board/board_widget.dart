library stack_board;

import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';

import '../../library/center_guides.dart';
import '../item/image/image_model.dart';
import '../item/image/image_widget.dart';
import '../item/item_model.dart';
import '../item/item_widget.dart';
import '../item/paint/paint_model.dart';
import '../item/paint/paint_widget.dart';
import '../item/text/text_model.dart';
import '../item/text/text_widget.dart';

/// 层叠板
class BoardWidget extends StatefulWidget {
  const BoardWidget({
    super.key,
    this.controller,
    this.background,
    this.customBuilder,
    this.tapItemToMoveToTop = true,
    this.enableCenterGuides = true,
  });

  @override
  BoardWidgetState createState() => BoardWidgetState();

  /// 层叠版控制器
  final StackBoardController? controller;

  /// 背景
  final Widget? background;

  final bool enableCenterGuides;

  /// 自定义类型控件构建器
  final Widget? Function(Item item)? customBuilder;

  /// 点击item移至顶层
  final bool tapItemToMoveToTop;
}

class BoardWidgetState extends State<BoardWidget> with SafeState<BoardWidget> {
  /// 子控件列表
  late List<Item> _children;

  int? _focusedItemId;

  /// 当前item所用id
  int _lastId = 0;

  /// 所有item的操作状态
  OperationState? _operationState;

  final CenterGuidesController _centerGuidesController =
      CenterGuidesController();

  /// 生成唯一Key
  Key _getKey(int? id) => Key('StackBoardItem$id');

  @override
  void initState() {
    super.initState();
    _children = <Item>[];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller?._stackBoardState = this;
  }

  /// 添加一个
  void _add<T extends Item>(Item item) {
    if (_children.contains(item)) throw 'duplicate id';

    _children.add(item.copyWith(
      id: item.id ?? _lastId,
    ));

    _lastId++;

    _unFocus(_children.last.id);
  }

  /// 移除指定id item
  void _remove(int? id) {
    _children.removeWhere((Item b) => b.id == id);
    safeSetState(() {});
  }

  /// 将item移至顶层
  void _moveItemToTop(int? id) {
    if (id == null) return;

    final Item item = _children.firstWhere((Item i) => i.id == id);
    _children.removeWhere((Item i) => i.id == id);
    _children.add(item);

    _unFocus(id);

    safeSetState(() {});
  }

  /// 清理
  void _clear() {
    _children.clear();
    _lastId = 0;
    safeSetState(() {});
  }

  /// 取消全部选中
  void _unFocus(int? id) {
    if (_focusedItemId == null) {
      _focusedItemId = id;
      _operationState = OperationState.complete;
      safeSetState(() {});
    }
  }

  /// 删除动作
  Future<void> _onDelete(Item box) async {
    final bool delete = (await box.onDelete?.call()) ?? true;
    if (delete) _remove(box.id);
  }

  @override
  Widget build(BuildContext context) {
    final Stack child = Stack(
      fit: StackFit.expand,
      children: [
        if (widget.background != null) widget.background!,
        ..._children.map((Item box) => _buildItem(box)).toList(),
        if (widget.enableCenterGuides)
          CenterGuides(
            controller: _centerGuidesController,
          ),
      ],
    );

    _focusedItemId = null;

    return child;
  }

  /// 构建项
  Widget _buildItem(Item item) {
    Widget child = ItemWidget(
      key: _getKey(item.id),
      onDelete: () => _onDelete(item),
      onPointerDown: () => _moveItemToTop(item.id),
      operationState:
          _focusedItemId == item.id ? OperationState.idle : _operationState,
      child: Container(
        width: 150,
        height: 150,
        alignment: Alignment.center,
        child: const Text(
            'Unknown item type, please use customBuilder to build it'),
      ),
    );

    if (item is TextItem) {
      child = TextItemWidget(
        key: _getKey(item.id),
        text: item.text,
        onDelete: () => _onDelete(item),
        onPointerDown: () => _moveItemToTop(item.id),
        operationState:
            _focusedItemId == item.id ? OperationState.idle : _operationState,
      );
    } else if (item is PaintItem) {
      child = PaintItemWidget(
        key: _getKey(item.id),
        onDelete: () => _onDelete(item),
        onPointerDown: () => _moveItemToTop(item.id),
        operationState:
            _focusedItemId == item.id ? OperationState.idle : _operationState,
      );
    } else if (item is ImageItem) {
      child = ImageItemWidget(
        key: _getKey(item.id),
        image: item.image,
        onDelete: () => _onDelete(item),
        onPointerDown: () => _moveItemToTop(item.id),
        operationState:
            _focusedItemId == item.id ? OperationState.idle : _operationState,
      );
    } else {
      child = ItemWidget(
        key: _getKey(item.id),
        onDelete: () => _onDelete(item),
        onPointerDown: () => _moveItemToTop(item.id),
        operationState:
            _focusedItemId == item.id ? OperationState.idle : _operationState,
        child: item.child,
      );

      if (widget.customBuilder != null) {
        final Widget? customWidget = widget.customBuilder!.call(item);
        if (customWidget != null) return child = customWidget;
      }
    }

    return child;
  }

  @override
  void dispose() {
    _centerGuidesController.dispose();
    super.dispose();
  }
}

/// 控制器
class StackBoardController {
  BoardWidgetState? _stackBoardState;
  late Shader printMaskShader;

  /// 检查是否加载
  void _done() {
    if (_stackBoardState == null) throw '_stackBoardState is empty';
  }

  /// 添加一个
  void add<T extends Item>(T item) {
    _done();
    _stackBoardState?._add<T>(item);
  }

  /// 移除
  void remove(int? id) {
    _done();
    _stackBoardState?._remove(id);
  }

  void moveItemToTop(int? id) {
    _done();
    _stackBoardState?._moveItemToTop(id);
  }

  /// 清理全部
  void clear() {
    _done();
    _stackBoardState?._clear();
  }

  /// 刷新
  void refresh() {
    _done();
    _stackBoardState?.safeSetState(() {});
  }

  /// 销毁
  void dispose() {
    _stackBoardState = null;
  }

  void unFocus([int? id]) {
    _stackBoardState?._unFocus(id);
  }

  void toggleCenterGuides({bool? newVerticalState, bool? newHorizontalState}) =>
      _stackBoardState?._centerGuidesController.toggleGuides(
        newVerticalState: newVerticalState,
        newHorizontalState: newHorizontalState,
      );
}
