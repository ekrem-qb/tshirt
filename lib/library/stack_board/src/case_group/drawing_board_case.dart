import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';

import '../helper/operat_state.dart';
import '../item_group/stack_drawing.dart';
import 'item_case.dart';

/// 画板外壳
class DrawingBoardCase extends StatefulWidget {
  const DrawingBoardCase({
    super.key,
    required this.stackDrawing,
    this.onDelete,
    this.operationState = OperationState.editing,
    this.onPointerDown,
  });

  @override
  DrawingBoardCaseState createState() => DrawingBoardCaseState();

  /// 画板配置对象
  final StackDrawing stackDrawing;

  /// 移除拦截
  final void Function()? onDelete;

  /// 点击回调
  final void Function()? onPointerDown;

  /// 操作状态
  final OperationState? operationState;
}

class DrawingBoardCaseState extends State<DrawingBoardCase>
    with SafeState<DrawingBoardCase> {
  /// 绘制控制器
  late DrawingController _drawingController;

  /// 绘制线条粗细进度
  late SafeValueNotifier<double> _indicator;

  /// 是否正在绘制
  late SafeValueNotifier<bool> _isDrawing;

  /// 操作状态
  OperationState? _operationState;

  /// 是否正在编辑
  bool _isEditing = true;

  @override
  void initState() {
    super.initState();
    _operationState = widget.operationState ?? OperationState.editing;
    _drawingController = DrawingController(config: DrawConfig.def());
    _indicator = SafeValueNotifier<double>(1);
    _isDrawing = SafeValueNotifier<bool>(false);
  }

  @override
  void didUpdateWidget(covariant DrawingBoardCase oldWidget) {
    if (widget.operationState != oldWidget.operationState) {
      safeSetState(() => _operationState = widget.operationState);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _drawingController.dispose();
    _indicator.dispose();
    _isDrawing.dispose();
    super.dispose();
  }

  /// 选择颜色
  Future<void> _pickColor() async {
    final Color? newColor = await showModalBottomSheet<Color?>(
        context: context,
        builder: (_) => ColorPic(nowColor: _drawingController.getColor));
    if (newColor == null) {
      return;
    }

    if (newColor != _drawingController.getColor) {
      _drawingController.setColor = newColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ItemCase(
      isCentered: false,
      isEditable: true,
      onPointerDown: widget.onPointerDown,
      tapToEdit: widget.stackDrawing.tapToEdit,
      editTools: _tools,
      operationState: _operationState,
      onDelete: widget.onDelete,
      caseStyle: widget.stackDrawing.caseStyle,
      onOperationStateChanged: (OperationState os) {
        if (os == OperationState.editing && !_isEditing) {
          _isEditing = true;
          safeSetState(() {});
        } else if (os != OperationState.editing && _isEditing) {
          _isEditing = false;
          safeSetState(() {});
        }

        return;
      },
      child: FittedBox(
        child: SizedBox.fromSize(
          size: widget.stackDrawing.size,
          child: Stack(
            children: <Widget>[
              FittedBox(
                child: SizedBox.fromSize(
                  size: widget.stackDrawing.size,
                  child: DrawingBoard(
                    controller: _drawingController,
                    background: widget.stackDrawing.child,
                    drawingCallback: (bool isDrawing) {
                      if (_isDrawing.value != isDrawing) {
                        _isDrawing.value = isDrawing;
                      }
                    },
                  ),
                ),
              ),
              if (!_isEditing) _mask,
            ],
          ),
        ),
      ),
    );
  }

  /// 绘制拦截图层
  Widget get _mask {
    return Positioned.fill(
      child: Container(color: Colors.transparent),
    );
  }

  /// 工具层
  Widget? get _tools {
    return Padding(
      padding: EdgeInsets.all(widget.stackDrawing.caseStyle!.iconSize / 2),
      child: Column(
        children: <Widget>[
          _toolBar,
          _buildActions,
        ],
      ),
    );
  }

  /// 工具栏
  Widget get _toolBar {
    return Row(
      children: <Widget>[
        _buildToolItem(PaintType.simpleLine, Icons.edit,
            () => _drawingController.setType = PaintType.simpleLine),
        _buildToolItem(PaintType.smoothLine, Icons.brush,
            () => _drawingController.setType = PaintType.smoothLine),
        _buildToolItem(PaintType.straightLine, Icons.show_chart,
            () => _drawingController.setType = PaintType.straightLine),
        _buildToolItem(PaintType.rectangle, Icons.crop_din,
            () => _drawingController.setType = PaintType.rectangle),
        _buildToolItem(PaintType.eraser, Icons.auto_fix_normal,
            () => _drawingController.setType = PaintType.eraser),
      ],
    );
  }

  /// 构建工具项
  Widget _buildToolItem(PaintType type, IconData icon, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: widget.stackDrawing.caseStyle!.iconSize * 1.5,
        height: widget.stackDrawing.caseStyle!.iconSize * 1.6,
        child: ExValueBuilder<DrawConfig>(
          valueListenable: _drawingController.drawConfig,
          shouldRebuild:
              (DrawConfig? previousDrawConfig, DrawConfig? newDrawConfig) =>
                  previousDrawConfig!.paintType == type ||
                  newDrawConfig!.paintType == type,
          builder: (_, DrawConfig? drawConfig, __) {
            return Icon(
              icon,
              color: drawConfig?.paintType == type
                  ? Theme.of(context).primaryColor
                  : null,
              size: widget.stackDrawing.caseStyle?.iconSize,
            );
          },
        ),
      ),
    );
  }

  /// 构建操作栏
  Widget get _buildActions {
    final double iconSize = widget.stackDrawing.caseStyle!.iconSize;

    return Row(
      children: <Widget>[
        Container(
          height: iconSize * 1.5,
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SliderTheme(
            data: SliderThemeData(
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: iconSize / 2.5,
                elevation: 0,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
            ),
            child: ExValueBuilder<double>(
              valueListenable: _indicator,
              builder: (_, double? ind, ___) {
                return Slider(
                  value: ind ?? 1,
                  max: 50,
                  min: 1,
                  divisions: 50,
                  label: ind?.floor().toString(),
                  onChanged: (double newValue) => _indicator.value = newValue,
                  onChangeEnd: (double newValue) =>
                      _drawingController.setThickness = newValue,
                );
              },
            ),
          ),
        ),
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: ExValueBuilder<DrawConfig?>(
            valueListenable: _drawingController.drawConfig,
            shouldRebuild:
                (DrawConfig? previousDrawConfig, DrawConfig? newDrawConfig) =>
                    previousDrawConfig!.color != newDrawConfig!.color,
            builder: (_, DrawConfig? drawConfig, ___) {
              return TextButton(
                onPressed: _pickColor,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: drawConfig?.color,
                  shape: const RoundedRectangleBorder(),
                ),
                child: const SizedBox.shrink(),
              );
            },
          ),
        ),
        GestureDetector(
          onTap: () => _drawingController.undo(),
          child: SizedBox(
            width: iconSize * 1.6,
            child: Icon(CupertinoIcons.arrow_turn_up_left, size: iconSize),
          ),
        ),
        GestureDetector(
          onTap: () => _drawingController.redo(),
          child: SizedBox(
            width: iconSize * 1.6,
            child: Icon(CupertinoIcons.arrow_turn_up_right, size: iconSize),
          ),
        ),
        GestureDetector(
          onTap: () => _drawingController.clear(),
          child: SizedBox(
            width: iconSize * 1.6,
            child: Icon(Icons.clear_all, size: iconSize),
          ),
        ),
      ],
    );
  }
}
