import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// 描述三角的相对位置
/// [start] - 三角在 [FFloat] 上下侧，表示三角和 [FFloat] 左边缘对齐；三角在 [FFloat] 左右侧，表示三角和 [FFloat] 上边缘对齐
/// [center] - 三角在 [FFloat] 上下侧，表示三角水平居中；三角在 [FFloat] 左右侧，表示三角垂直居中
/// [end] - 三角在 [FFloat] 上下侧，表示三角和 [FFloat] 右边缘对齐；三角在 [FFloat] 左右侧，表示三角和 [FFloat] 下边缘对齐
///
/// Describe the relative position of the triangle
/// [start]-The triangle is above and below [FFloat], indicating that the triangle is aligned with the left edge of [FFloat];
///   the triangle is on the left and right of [FFloat], indicating that the triangle is aligned with the top edge of [FFloat]
/// [center] - The triangle is above and below [FFloat], indicating that the triangle is horizontally centered;
///   the triangle is on the left and right sides of [FFloat], indicating that the triangle is vertically centered
/// [end] - The triangle is above and below [FFloat], indicating that the triangle is aligned with the right edge of [FFloat];
///   the triangle is on the left and right of [FFloat], indicating that the triangle is aligned with the bottom edge of [FFloat]
enum TriangleAlignment {
  start,
  center,
  end,
}

/// 描述 [FFloat] 相对于锚点元素的位置。
/// topLeft - 在锚点元素【上方】，且【左边缘】与锚点元素对齐
/// topCenter - 在锚点元素【上方】，且水平居中
/// topRight - 在锚点元素【上方】，且【右边缘】与锚点元素对齐
/// bottomLeft - 在锚点元素【下方】，且【左边缘】与锚点元素对齐
/// bottomCenter -  在锚点元素【下方】，且水平居中
/// bottomRight -  在锚点元素【下方】，且【右边缘】与锚点元素对齐
/// leftTop - 在锚点元素【左侧】，且【上边缘】与锚点元素对齐
/// leftCenter - 在锚点元素【左侧】，且垂直居中
/// leftBottom - 在锚点元素【左侧】，且【下边缘】与锚点元素对齐
/// rightTop - 在锚点元素【右侧】，且【上边缘】与锚点元素对齐
/// rightCenter - 在锚点元素【右侧】，且垂直居中
/// rightBottom - 在锚点元素【右侧】，且【下边缘】与锚点元素对齐
///
/// Description [FFloat] The position relative to the anchor element.
/// topLeft - In the anchor element [above], and the [leftEdge] is aligned with the anchor element
/// topCenter - In the anchor element [above], and horizontally centered
/// topRight - In the anchor element [above], and the [rightEdge] is aligned with the anchor element
/// bottomLeft - In the anchor element [below], and the [leftEdge] is aligned with the anchor element
/// bottomCenter -  In the anchor element [below], and horizontally centered
/// bottomRight -  In the anchor element [below], and the [rightEdge] is aligned with the anchor element
/// leftTop - In the anchor element [left], and the [upperEdge] is aligned with the anchor element
/// leftCenter - In the anchor element [left], and vertically centered
/// leftBottom - In the anchor element [left], and the [bottomEdge] is aligned with the anchor element
/// rightTop - In the anchor element [right], and the [upperEdge] is aligned with the anchor element
/// rightCenter - In the anchor element [right], and vertically centered
/// rightBottom - In the anchor element [right side], and the [bottomEdge] is aligned with the anchor element
enum FFloatAlignment {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
  leftTop,
  leftCenter,
  leftBottom,
  rightTop,
  rightCenter,
  rightBottom,
}

/// 用于返回一个 [Widget]，如果只更新内容区域的话，通过 setter((){}) 进行
///
/// Used to return a [Widget], if only the content area is updated, through setter (() {})
typedef FloatBuilder = Widget Function(
    StateSetter setter, State<FFloatContent> contentState);

/// [FFloat] 能够在屏幕的任意位置浮出一个组件。甚至可以基于 [child] 锚点组件来动态的确定漂浮组件的位置。
/// [FFloat] 同时提供了绝妙的配置选项。圆角、描边、背景、偏移、装饰三角。
/// [FFloat] 设置了 [FFloatController] 控制器，可以方便的随时对漂浮组件进行控制。
///
/// [FFloat] can float a component anywhere on the screen. You can even dynamically determine the position of the floating component based on the [child] anchor component.
/// [FFloat] also provides wonderful configuration options. Fillet, stroke, background, offset, decorative triangle.
/// [FFloat] The [FFloatController] controller is set, which can easily control the floating component at any time.
// ignore: must_be_immutable
class FFloat extends StatefulWidget {
  /// 通过 [FloatBuilder] 返回 [FFloat] 的内容组件。
  /// 如果只更新内容区域的话，通过 setter((){}) 进行
  ///
  /// [FloatBuilder] returns the content component of [FFloat].
  /// If only the content area is updated, proceed via setter (() {})
  final FloatBuilder builder;

  /// 锚点组件
  ///
  /// Anchor component
  final Widget child;

  /// [FFloat] 基于 [child] 锚点元素的相对位置。
  ///
  /// [FFloat] Based on the relative position of the [child] anchor element.
  final FFloatAlignment alignment;

  /// 通过 [FFloatController] 可以控制 [FFloat] 的显示/隐藏。详见 [FFloatController]。
  ///
  /// [FFloatController] can control the display / hide of [FFloat]. See [FFloatController] for details.
  final FFloatController? controller;

  _FFloat? _float;

  FFloat(
    this.builder, {
    super.key,
    required this.child,
    this.alignment = FFloatAlignment.topCenter,
    this.controller,
  });

  @override
  FFloatState createState() => FFloatState();

  void show(BuildContext context) {
    _float = _FFloat(
      context,
      builder,
      alignment: alignment,
      controller: controller,
    );
    _float!.show();
  }

  void dismiss() {
    if (_float != null) {
      _float!.dismiss();
    }
  }
}

class FFloatState extends State<FFloat> {
  Offset? anchorLocation;
  Size? anchorSize;

  _FFloat? _float;
  final anchorKey = GlobalKey();

  @override
  void initState() {
    init();
    postUpdateCallback();
    super.initState();
  }

  void init() {
    createFloat(context);
  }

  void createFloat(BuildContext context) {
    _float = _FFloat(
      context,
      widget.builder,
      alignment: widget.alignment,
      controller: widget.controller,
    );
  }

  void postUpdateCallback() {
    WidgetsBinding.instance.addPostFrameCallback((time) {
      if (!mounted) return;
      RenderBox? stack = context.findRenderObject() as RenderBox?;
      RenderBox? anchor =
          anchorKey.currentContext!.findRenderObject() as RenderBox?;
      Offset? anchorLocation = anchor?.localToGlobal(Offset.zero);
      Offset? location = stack?.globalToLocal(anchorLocation ?? Offset.zero);
      Size? size = anchor?.size;
      bool needUpdate = false;
      if (location != null && location != anchorLocation) {
        needUpdate = true;
        anchorLocation = location;
      }
      if (size != null && size != anchorSize) {
        needUpdate = true;
        anchorSize = size;
      }
      if (_float != null && needUpdate) {
        _float!.update(anchorSize, anchorLocation);
      }
      postUpdateCallback();
    });
  }

  @override
  void dispose() {
    if (_float != null) {
      _float!.dispose();
      _float = null;
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(FFloat oldWidget) {
    if (_float != null) {
      asyncParams();
    }
    super.didUpdateWidget(oldWidget);
  }

  void asyncParams() {
    if (_float == null) return;
    _float!
      ..context = context
      ..builder = widget.builder
      ..alignment = widget.alignment
      ..controller = widget.controller;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      // clipBehavior: Clip.none,
      children: [
        Builder(
          key: anchorKey,
          builder: (_) => widget.child,
        ),
        FFloatContent(
          _float!.childLocation ?? Offset.zero,
          widget.builder,
          anchorSize: _float!.childSize ?? Size.zero,
          alignment: widget.alignment,
          controller: _float!.ffloatContentController,
          notifier: _float!.notifier,
          initShow: _float!.isShow,
        ),
      ],
    );
  }
}

class _FFloat {
  FFloatAlignment alignment;
  FloatBuilder builder;
  FFloatController? controller;

  Offset? childLocation;
  Size? childSize;

  OverlayEntry? _overlayEntry;
  bool _isShow = false;

  bool get isShow => _isShow;

  set isShow(bool value) {
    if (_isShow == value) return;
    _isShow = value;
    controller?.isShow = value;
  }

  Timer? dismissTimer;

  FFloatContentController? ffloatContentController;

  ValueNotifier<int>? notifier;

  BuildContext context;

  _FFloat(
    this.context,
    this.builder, {
    this.alignment = FFloatAlignment.topCenter,
    this.controller,
  }) {
    init();
  }

  void init() {
    notifier = ValueNotifier(0);
    notifier!.addListener(() {
      if (notifier!.value == 0) {
        realDismiss();
      }
    });
    ffloatContentController = FFloatContentController();
    controller?._show = () {
      show();
    };
    controller?._dismiss = () {
      dismiss();
    };
    controller?._rebuildShow = () {
      rebuildShow();
    };
    controller?._setState = (VoidCallback fn) {
      ffloatContentController?.setState(fn);
    };
  }

  void update(Size? anchorSize, Offset? location) {
    childSize = anchorSize;
    childLocation = location;
    if (ffloatContentController != null && isShow) {
      ffloatContentController!.update(anchorSize, location);
    }
  }

  void dispose() {
    controller?.dispose();
    ffloatContentController?.dispose();
    if (dismissTimer != null && dismissTimer!.isActive) {
      dismissTimer!.cancel();
      dismissTimer = null;
    }
  }

  void show() {
    /// Prevent duplicate display
    if (isShow) return;
    isShow = true;
    ffloatContentController?.playAnimForward();
  }

  void rebuildShow() {
    ffloatContentController?.playAnimForward();
  }

  void dismiss() {
    if (isShow) {
      isShow = false;
      ffloatContentController?.playAnimBackward();
      if (dismissTimer != null && dismissTimer!.isActive) {
        dismissTimer!.cancel();
        dismissTimer = null;
      }
      if (notifier != null) {
        notifier!.value = 1;
      }
    }
  }

  void realDismiss() {
    isShow = false;
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }
}

class FFloatContent extends StatefulWidget {
  Offset location;
  FloatBuilder? builder;
  Size anchorSize;
  FFloatAlignment alignment;
  FFloatContentController? controller;
  ValueNotifier? notifier;
  bool? initShow;

  FFloatContent(
    this.location,
    this.builder, {
    super.key,
    this.anchorSize = Size.zero,
    this.alignment = FFloatAlignment.topCenter,
    this.controller,
    this.notifier,
    this.initShow,
  });

  @override
  FFloatContentState createState() => FFloatContentState();
}

class FFloatContentState extends State<FFloatContent>
    with TickerProviderStateMixin {
  GlobalKey key = GlobalKey();
  Size? areaSize;
  Offset? location;
  Size? anchorSize;
  AnimationController? animationController;
  late Animation<double> scaleAnimation;
  bool? init;

  @override
  void initState() {
    init = true;
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    scaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(animationController!);
    scaleAnimation.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    scaleAnimation.addStatusListener((status) {
      if ((status == AnimationStatus.dismissed ||
              status == AnimationStatus.completed) &&
          widget.notifier != null &&
          widget.notifier!.value == 1) {
        widget.notifier!.value = 0;
      }
    });
    if (widget.notifier != null) {
      widget.notifier!.addListener(onNotifier);
    }
    location = widget.location;
    anchorSize = widget.anchorSize;
    if (widget.controller != null) {
      widget.controller!.state = this;
    }
    postUpdateCallback();
  }

  void onNotifier() {
    if (mounted &&
        widget.notifier != null &&
        widget.notifier!.value == 1 &&
        animationController != null) {
      animationController!.reverse(from: 1.0);
    }
  }

  void _setState(Function? func) {
    if (mounted && func != null) {
      setState(() {
        func();
      });
    }
  }

  void postUpdateCallback() {
    WidgetsBinding.instance.addPostFrameCallback((time) {
      if (!mounted) return;
      Size? size = context.size;
      if (size != null && areaSize != size) {
        areaSize = size;
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(FFloatContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    location = widget.location;
    anchorSize = widget.anchorSize;
  }

  @override
  void dispose() {
    if (widget.notifier != null) {
      widget.notifier!.removeListener(onNotifier);
    }
    if (animationController != null) {
      animationController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Offset areaOffset = calculateAreaOffset();

    return Positioned(
      left: location!.dx + areaOffset.dx,
      top: location!.dy + areaOffset.dy,
      child: Transform.scale(
        scale: scaleAnimation.value,
        alignment: matchScaleAnim(widget.anchorSize == Size.zero),
        child: widget.builder != null
            ? widget.builder!.call(setState, this)
            : Container(),
      ),
    );
  }

  Alignment matchScaleAnim(bool center) {
    if (center) return Alignment.center;
    switch (widget.alignment) {
      case FFloatAlignment.topLeft:
        return Alignment.bottomLeft;
      case FFloatAlignment.topCenter:
        return Alignment.bottomCenter;
      case FFloatAlignment.topRight:
        return Alignment.bottomRight;
      case FFloatAlignment.bottomLeft:
        return Alignment.topLeft;
      case FFloatAlignment.bottomCenter:
        return Alignment.topCenter;
      case FFloatAlignment.bottomRight:
        return Alignment.topRight;
      case FFloatAlignment.leftTop:
        return Alignment.topRight;
      case FFloatAlignment.leftCenter:
        return Alignment.centerRight;
      case FFloatAlignment.leftBottom:
        return Alignment.bottomRight;
      case FFloatAlignment.rightTop:
        return Alignment.topLeft;
      case FFloatAlignment.rightCenter:
        return Alignment.centerLeft;
      case FFloatAlignment.rightBottom:
        return Alignment.bottomLeft;
    }
  }

  Offset calculateAreaOffset() {
    if (areaSize == null) return Offset.zero;
    switch (widget.alignment) {
      case FFloatAlignment.topLeft:
        return Offset(
          0,
          -areaSize!.height,
        );
      case FFloatAlignment.topCenter:
        return Offset(
          anchorSize!.width / 2.0 - areaSize!.width / 2.0,
          -areaSize!.height,
        );
      case FFloatAlignment.topRight:
        return Offset(
          anchorSize!.width - areaSize!.width,
          -areaSize!.height,
        );
      case FFloatAlignment.bottomLeft:
        return Offset(
          0,
          anchorSize!.height,
        );
      case FFloatAlignment.bottomCenter:
        return Offset(
          anchorSize!.width / 2.0 - areaSize!.width / 2.0,
          anchorSize!.height,
        );

      case FFloatAlignment.bottomRight:
        return Offset(
          anchorSize!.width - areaSize!.width,
          anchorSize!.height,
        );

      case FFloatAlignment.leftTop:
        return Offset(
          -areaSize!.width,
          0,
        );

      case FFloatAlignment.leftCenter:
        return Offset(
          -areaSize!.width,
          anchorSize!.height / 2.0 - areaSize!.height / 2.0,
        );

      case FFloatAlignment.leftBottom:
        return Offset(
          -areaSize!.width,
          anchorSize!.height - areaSize!.height,
        );

      case FFloatAlignment.rightTop:
        return Offset(
          anchorSize!.width,
          0,
        );

      case FFloatAlignment.rightCenter:
        return Offset(
          anchorSize!.width,
          anchorSize!.height / 2.0 - areaSize!.height / 2.0,
        );

      case FFloatAlignment.rightBottom:
        return Offset(
          anchorSize!.width,
          anchorSize!.height - areaSize!.height,
        );
    }
  }

  double calculateTriangleRotate() {
    switch (widget.alignment) {
      case FFloatAlignment.topLeft:
      case FFloatAlignment.topCenter:
      case FFloatAlignment.topRight:
        return pi;
      case FFloatAlignment.bottomLeft:
      case FFloatAlignment.bottomCenter:
      case FFloatAlignment.bottomRight:
        return 0.0;
      case FFloatAlignment.leftTop:
      case FFloatAlignment.leftCenter:
      case FFloatAlignment.leftBottom:
        return pi / 2.0;
      case FFloatAlignment.rightTop:
      case FFloatAlignment.rightCenter:
      case FFloatAlignment.rightBottom:
        return -pi / 2.0;
    }
  }
}

class FFloatContentController {
  FFloatContentState? state;

  setState(VoidCallback fn) {
    state?._setState(fn);
  }

  update(Size? anchorSize, Offset? location) {
    setState(() {
      state!.anchorSize = anchorSize;
      state!.location = location;
    });
  }

  playAnimForward() {
    state?.animationController?.forward();
  }

  playAnimBackward() {
    state?.animationController?.reverse();
  }

  dispose() {
    state = null;
  }
}

/// 通过 [FFloatController] 可以控制 [FFloat] 的显示、隐藏，以及感知状态变化。
///
/// [FFloatController] can control [FFloat] display, hide, and sense state changes.
class FFloatController {
  VoidCallback? _callback;

  bool _isShow = false;

  /// [FFloat] 是否显示
  ///
  /// [FFloat] Whether to display
  bool get isShow => _isShow;

  set isShow(bool value) {
    if (_isShow == value) return;
    _isShow = value;
    if (_callback != null) {
      _callback!();
    }
  }

//  _FFloatState _state;

  VoidCallback? _show;
  VoidCallback? _dismiss;
  VoidCallback? _rebuildShow;
  StateSetter? _setState;

  /// 隐藏 [FFloat]
  ///
  /// Hide [FFloat]
  void dismiss() {
    if (_dismiss != null) {
      _dismiss!();
    }
  }

  /// 显示 [FFloat]。如果已经显示，将不会再次重建。
  ///
  /// Show [FFloat]。If it is already displayed, it will not be rebuilt again.
  void show() {
    if (_show != null) {
      _show!();
    }
  }

  /// 显示 [FFloat]。会重建。
  ///
  /// [FFloat] is displayed. Will rebuild.
  void rebuildShow() {
    if (_rebuildShow != null) {
      _rebuildShow!();
    }
  }

  /// 销毁
  ///
  /// destroy
  dispose() {
//    _callback = null;
  }

  /// 设置监听。当 [FFloat] 显示状态发生变化的时候会回调。
  ///
  /// Set up monitoring. It will be called back when [FFloat] display status changes.
  setStateChangedListener(VoidCallback listener) {
    _callback = listener;
  }

  setState(VoidCallback fn) {
    _setState?.call(fn);
  }
}
