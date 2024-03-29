import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:provider/provider.dart';

import '../../../theme.dart';
import '../../library/ffloat.dart';
import '../constructor_model.dart';
import 'item_model.dart';

/// 配置项
class Config {
  Config({
    this.size,
    this.offset = Offset.zero,
    this.angle = 0,
    this.flipMatrix,
  });

  /// 尺寸
  Size? size;

  /// 位置
  Offset offset;

  /// 角度
  double angle;

  Matrix4? flipMatrix;

  /// 拷贝
  Config copy({
    Size? size,
    Offset? offset,
    double? angle,
    Matrix4? flipMatrix,
  }) =>
      Config(
        size: size ?? this.size,
        offset: offset ?? this.offset,
        angle: angle ?? this.angle,
        flipMatrix: flipMatrix ?? this.flipMatrix,
      );
}

/// 操作外壳
class ItemWidget extends StatefulWidget {
  const ItemWidget({
    super.key,
    this.controller,
    required this.child,
    this.isCentered = false,
    this.editTools,
    this.operationState = OperationState.idle,
    this.isEditable = false,
    this.onDelete,
    this.onSizeChanged,
    this.onResizeDone,
    this.onOperationStateChanged,
    this.onOffsetChanged,
    this.onAngleChanged,
    this.onPointerDown,
    this.onFlipped,
  });

  @override
  ItemWidgetState createState() => ItemWidgetState();

  final ItemController? controller;

  /// 子控件
  final Widget child;

  /// 工具层
  final Widget? editTools;

  /// 是否进行居中对齐(自动包裹Center)
  final bool isCentered;

  /// 能否编辑
  final bool isEditable;

  /// 操作状态
  final OperationState? operationState;

  /// 移除拦截
  final void Function()? onDelete;

  /// 点击回调
  final void Function()? onPointerDown;

  /// 尺寸变化回调
  /// 返回值可控制是否继续进行
  final bool? Function(Size size)? onSizeChanged;

  final bool? Function(Size size)? onResizeDone;

  ///位置变化回调
  final bool? Function(Offset offset)? onOffsetChanged;

  /// 角度变化回调
  final bool? Function(double offset)? onAngleChanged;

  final bool? Function(Matrix4 flipMatrix)? onFlipped;

  /// 操作状态回调
  final bool? Function(OperationState)? onOperationStateChanged;
}

class ItemWidgetState extends State<ItemWidget> with SafeState<ItemWidget> {
  /// 基础参数状态
  late SafeValueNotifier<Config> config;

  /// 操作状态
  OperationState _operationState = OperationState.idle;
  OperationState get operationState => _operationState;
  set operationState(OperationState newOperationState) {
    if (newOperationState == OperationState.editing) {
      _fFloatController.show();
    } else {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _fFloatController.dismiss());
    }
    _operationState = newOperationState;
    widget.onOperationStateChanged?.call(newOperationState);
  }

  static const int moveSnappingTreshold = 15;
  late Size originalSize;
  static const double minWidthAndHeight = CaseStyle.iconSize * 3;
  late double maxWidthAndHeight;
  final itemKey = GlobalKey();
  late Offset center;
  late Offset movingStartPosition;
  late Offset movingStartOffset;
  late Offset rotatingPointerOffset;
  late double rotatingStartAngle;
  late Size currentUnfittedSize;

  late Constructor? _constructorModel;
  final FFloatController _fFloatController = FFloatController();

  @override
  void initState() {
    super.initState();
    operationState = widget.operationState ?? OperationState.idle;
    config = SafeValueNotifier<Config>(Config());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    maxWidthAndHeight = MediaQuery.of(context).size.longestSide;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recalculateCenter();
    });
    _constructorModel = context.read<Constructor>();
    widget.controller?._itemState = this;
  }

  @override
  void didUpdateWidget(covariant ItemWidget oldWidget) {
    operationState = widget.operationState!;
    safeSetState(() {});
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    config.dispose();
    super.dispose();
  }

  Offset _recalculateCenter() {
    final Offset ownerCenter = (context
                .findAncestorRenderObjectOfType<RenderObject>()
                ?.paintBounds
                .center ??
            Offset.zero) +
        printOffsetFromCenter;
    final Offset selfCenter = config.value.size?.center(Offset.zero) ??
        itemKey.currentContext?.size?.center(Offset.zero) ??
        Offset.zero;
    center = ownerCenter - selfCenter;
    return center;
  }

  /// 切回常规状态
  void _changeToIdle() {
    if (operationState != OperationState.idle) {
      operationState = OperationState.idle;

      safeSetState(() {});
    }
  }

  void _movingStart(DragStartDetails dragStartDetails) {
    movingStartPosition = dragStartDetails.globalPosition;
    movingStartOffset = config.value.offset;
  }

  /// 移动操作
  void _moveHandle(DragUpdateDetails dragUpdateDetails) {
    if (operationState != OperationState.moving) {
      if (operationState == OperationState.scaling ||
          operationState == OperationState.rotating) {
        operationState = OperationState.moving;
      } else {
        operationState = OperationState.moving;
        safeSetState(() {});
      }
    }

    Offset newOffset = movingStartOffset +
        (dragUpdateDetails.globalPosition - movingStartPosition);

    if ((newOffset.dx - center.dx).abs() < moveSnappingTreshold) {
      newOffset = Offset(center.dx, newOffset.dy);
      _constructorModel?.toggleCenterGuides(newVerticalState: true);
    } else {
      _constructorModel?.toggleCenterGuides(newVerticalState: false);
    }
    if ((newOffset.dy - center.dy).abs() < moveSnappingTreshold) {
      newOffset = Offset(newOffset.dx, center.dy);
      _constructorModel?.toggleCenterGuides(newHorizontalState: true);
    } else {
      _constructorModel?.toggleCenterGuides(newHorizontalState: false);
    }

    //移动拦截
    if (!(widget.onOffsetChanged?.call(newOffset) ?? true)) return;

    config.value = config.value.copy(offset: newOffset);
  }

  /// 缩放操作
  void _scaleHandle(
    Offset scaleOffset, {
    bool cancelEditMode = true,
    bool keepAspectRatio = true,
  }) {
    if (cancelEditMode) {
      if (operationState != OperationState.scaling) {
        if (operationState == OperationState.moving ||
            operationState == OperationState.rotating) {
          operationState = OperationState.scaling;
        } else {
          operationState = OperationState.scaling;
          safeSetState(() {});
        }
      }
    }

    if (config.value.size == null) return;

    currentUnfittedSize = Size(
      currentUnfittedSize.width + (scaleOffset.dx * 2),
      currentUnfittedSize.height + (scaleOffset.dy * 2),
    );

    Size fittedSize;

    if (keepAspectRatio) {
      fittedSize = applyBoxFit(
        BoxFit.contain,
        originalSize,
        currentUnfittedSize,
      ).destination;
    } else {
      fittedSize = currentUnfittedSize;
    }

    fittedSize = Size(
      fittedSize.width.clamp(minWidthAndHeight, maxWidthAndHeight),
      fittedSize.height.clamp(minWidthAndHeight, maxWidthAndHeight),
    );

    if (fittedSize.width > minWidthAndHeight &&
        fittedSize.height > minWidthAndHeight &&
        fittedSize.width < maxWidthAndHeight &&
        fittedSize.height < maxWidthAndHeight) {
      config.value.offset = Offset(
        config.value.offset.dx -
            ((fittedSize.width - config.value.size!.width) / 2),
        config.value.offset.dy -
            ((fittedSize.height - config.value.size!.height) / 2),
      );

      // //移动拦截
      if (!(widget.onOffsetChanged?.call(config.value.offset) ?? true)) return;

      config.value.size = fittedSize;

      //缩放拦截
      if (!(widget.onSizeChanged?.call(config.value.size!) ?? true)) return;

      config.value = config.value.copy();

      _recalculateCenter();
    }
  }

  void _scalingEnd(DragEndDetails dragEndDetails) {
    if (config.value.size != null) {
      currentUnfittedSize = config.value.size!;
    }
    _changeToIdle();
    if (!(widget.onResizeDone?.call(config.value.size!) ?? true)) return;
  }

  void _rotationStart(DragStartDetails dragStartDetails) {
    rotatingPointerOffset = config.value.offset;
    rotatingStartAngle = config.value.angle;
  }

  /// 旋转操作
  void _rotateHandle(DragUpdateDetails dragUpdateDetails) {
    if (operationState != OperationState.rotating) {
      if (operationState == OperationState.moving ||
          operationState == OperationState.scaling) {
        operationState = OperationState.rotating;
      } else {
        operationState = OperationState.rotating;
        safeSetState(() {});
      }
    }

    if (config.value.size == null) return;

    rotatingPointerOffset += dragUpdateDetails.delta;
    final Offset start = config.value.offset;
    final Size size = config.value.size!;
    final Offset center = size.center(start);
    final Offset directionToPointer = rotatingPointerOffset - center;
    final Offset directionToHandle = start - center;

    final double angle = rotatingStartAngle +
        math.atan2(directionToPointer.dy, directionToPointer.dx) -
        math.atan2(directionToHandle.dy, directionToHandle.dx);

    //旋转拦截
    if (!(widget.onAngleChanged?.call(angle) ?? true)) return;

    final double roundedAngle = (angle / (math.pi / 4)).round() * (math.pi / 4);
    final bool isNearToSnap = (angle - roundedAngle).abs() < 0.1;

    config.value =
        config.value.copy(angle: isNearToSnap ? roundedAngle : angle);
  }

  /// 旋转回0度
  void _turnBack() {
    if (config.value.angle != 0) {
      config.value = config.value.copy(angle: 0);
    }
  }

  void _flip({required bool vertical}) {
    final Matrix4 newFlipMatrix = config.value.flipMatrix ?? Matrix4.identity();

    if (vertical) {
      newFlipMatrix.rotateX(math.pi);
    } else {
      newFlipMatrix.rotateY(math.pi);
    }

    config.value = config.value.copy(flipMatrix: newFlipMatrix);

    if (!(widget.onFlipped?.call(newFlipMatrix) ?? true)) return;

    safeSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ExValueBuilder<Config>(
      shouldRebuild: (Config? previousConfig, Config? newConfig) =>
          previousConfig?.size != newConfig?.size ||
          previousConfig?.offset != newConfig?.offset ||
          previousConfig?.angle != newConfig?.angle,
      valueListenable: config,
      builder: (_, Config? config, Widget? child) {
        return Offstage(
          offstage: config?.size == null,
          child: Listener(
            onPointerDown: (_) => widget.onPointerDown?.call(),
            child: Stack(
              children: [
                ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (_) => _constructorModel!.printMaskShader,
                  child: Stack(
                    children: [
                      Positioned(
                        top: config?.offset.dy,
                        left: config?.offset.dx,
                        width: config?.size?.width,
                        height: config?.size?.height,
                        child: Transform.rotate(
                          angle: config?.angle ?? 0,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanStart: _movingStart,
                            onPanUpdate: _moveHandle,
                            onPanEnd: (_) {
                              _changeToIdle();
                              _constructorModel?.toggleCenterGuides(
                                newVerticalState: false,
                                newHorizontalState: false,
                              );
                            },
                            child: _child,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FFloat(
                  (setter, contentState) {
                    return widget.editTools != null
                        ? widget.editTools!
                        : const SizedBox.shrink();
                  },
                  controller: _fFloatController,
                  alignment: FFloatAlignment.bottomCenter,
                  child: Positioned(
                    top: config?.offset.dy,
                    left: config?.offset.dx,
                    width: config?.size?.width,
                    height: config?.size?.height,
                    child: Transform.rotate(
                      angle: config?.angle ?? 0,
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: operationState != OperationState.complete
          ? Stack(
              key: itemKey,
              fit: StackFit.passthrough,
              children: [
                _border,
                _flipY,
                _rotate,
                _flipX,
                if (widget.onDelete != null) _delete,
                if (widget.isEditable) _edit,
                _scale,
              ],
            )
          : null,
    );
  }

  /// 子控件
  Widget get _child {
    Widget content = widget.child;
    if (config.value.size == null) {
      content = GetSize(
        onChange: (Size? size) {
          if (size != null && config.value.size == null) {
            config.value.size = Size(size.width + CaseStyle.iconSize,
                size.height + CaseStyle.iconSize);
            originalSize = config.value.size!;
            currentUnfittedSize = originalSize;

            config.value.offset = _recalculateCenter();
            safeSetState(() {});
          }
        },
        child: content,
      );
    }

    if (widget.isCentered) content = Center(child: content);

    return Padding(
      padding: const EdgeInsets.all(CaseStyle.iconSize / 2),
      child: content,
    );
  }

  /// 边框
  Widget get _border {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.all(CaseStyle.iconSize / 2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: CaseStyle.borderColor,
              width: CaseStyle.borderWidth,
            ),
          ),
        ),
      ),
    );
  }

  /// 编辑手柄
  Widget get _edit {
    return Align(
      alignment: Alignment.bottomLeft,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            if (operationState == OperationState.editing) {
              operationState = OperationState.idle;
            } else {
              operationState = OperationState.editing;
            }
            setState(() {});
          },
          child: _toolCase(
            Icon(operationState == OperationState.editing
                ? Icons.border_color
                : Icons.edit),
          ),
        ),
      ),
    );
  }

  /// 删除手柄
  Widget get _delete {
    return Align(
      alignment: Alignment.topRight,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            _fFloatController.dismiss();
            _fFloatController.dispose();
            widget.onDelete?.call();
          },
          child: _toolCase(const Icon(Icons.clear)),
        ),
      ),
    );
  }

  /// 缩放手柄
  Widget get _scale {
    return Align(
      alignment: Alignment.bottomRight,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeUpLeftDownRight,
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails dragUpdateDetails) =>
              _scaleHandle(dragUpdateDetails.delta),
          onPanEnd: _scalingEnd,
          child: _toolCase(
            const RotatedBox(
              quarterTurns: 1,
              child: Icon(Icons.open_in_full_outlined),
            ),
          ),
        ),
      ),
    );
  }

  /// 旋转手柄
  Widget get _rotate {
    return Align(
      alignment: Alignment.topLeft,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onPanStart: _rotationStart,
          onPanUpdate: _rotateHandle,
          onPanEnd: (_) => _changeToIdle(),
          onDoubleTap: _turnBack,
          child: _toolCase(
            const Icon(Icons.refresh),
          ),
        ),
      ),
    );
  }

  /// 旋转手柄
  Widget get _flipX {
    return Align(
      alignment: Alignment.topCenter,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _flip(vertical: true),
          child: _toolCase(
            const RotatedBox(
              quarterTurns: 1,
              child: Icon(Icons.flip),
            ),
          ),
        ),
      ),
    );
  }

  /// 旋转手柄
  Widget get _flipY {
    return Align(
      alignment: Alignment.centerLeft,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _flip(vertical: false),
          child: _toolCase(
            const Icon(Icons.flip),
          ),
        ),
      ),
    );
  }

  /// 操作手柄壳
  Widget _toolCase(Widget child) {
    return SizedBox(
      width: CaseStyle.iconSize,
      height: CaseStyle.iconSize,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: CaseStyle.borderColor,
        ),
        child: IconTheme(
          data: Theme.of(context).iconTheme.copyWith(
                color: CaseStyle.iconColor,
                size: CaseStyle.iconSize * 0.5,
              ),
          child: child,
        ),
      ),
    );
  }
}

class ItemController {
  ItemWidgetState? _itemState;

  void resizeCase(Offset scaleOffset) {
    _itemState?._scaleHandle(
      scaleOffset / 2,
      cancelEditMode: false,
      keepAspectRatio: false,
    );
    _itemState?.safeSetState(() => {});
  }

  void setOriginalSize(Size newSize) {
    _itemState?.originalSize = newSize;
  }

  void dispose() {
    _itemState = null;
  }

  SafeValueNotifier<Config>? get config => _itemState?.config;
}
