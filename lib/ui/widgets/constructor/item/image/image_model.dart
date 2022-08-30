import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../providers/library/image_provider_extension.dart';
import '../../../../../resources/filters.dart';
import '../item_model.dart';
import '../item_widget.dart';
import 'edit_tools/mask_picker/mask_picker_model.dart';

class ImageItem extends Item with ChangeNotifier {
  ImageItem(
    this._image, {
    super.id,
    super.onDelete,
    bool? tapToEdit,
  }) : super(
          child: const SizedBox.shrink(),
          tapToEdit: tapToEdit ?? false,
        );

  @override
  ImageItem copyWith({
    ImageProvider? image,
    int? id,
    Widget? child,
    Future<bool> Function()? onDelete,
    bool? tapToEdit,
  }) {
    return ImageItem(
      image ?? this.image,
      id: id ?? this.id,
      onDelete: onDelete ?? this.onDelete,
      tapToEdit: tapToEdit ?? this.tapToEdit,
    );
  }

  static const Size defaultSize = Size(100, 100);
  static const double sizeChangeTreshold = 1.5;

  Size caseSize = defaultSize;
  final ItemController itemController = ItemController();

  Matrix4 _flipMatrix = Matrix4.identity();
  Matrix4 get flipMatrix => _flipMatrix;
  set flipMatrix(Matrix4 flipMatrix) {
    _flipMatrix = flipMatrix;
    notifyListeners();
  }

  String? _maskSvgString;
  String? get maskSvgString => _maskSvgString;
  set maskSvgString(String? newSvgString) {
    _maskSvgString = newSvgString;
    if (newSvgString != null) {
      _parseSvg();
    } else {
      maskShader = null;
    }
  }

  late DrawableRoot _maskSvg;
  late ui.Image _maskSvgImage;
  late Size _maskSvgOldSize;
  late Size _maskSvgCurrentSize;

  ImageProvider _image;

  ImageProvider get image => _image;

  set image(ImageProvider newImage) {
    _image = newImage;
    calculateImageSize();
  }

  Size? imageSize;

  ImageShader? _maskShader;
  ImageShader? get maskShader => _maskShader;
  set maskShader(ImageShader? maskShader) {
    _maskShader = maskShader;
    notifyListeners();
  }

  List<double> _filter = filterPresets.values.first;
  List<double> get filter => _filter;
  set filter(List<double> filter) {
    _filter = filter;
    notifyListeners();
  }

  void calculateImageSize() async {
    final imageInfo = await image.getImageInfo();
    imageSize = ui.Size(
      (imageInfo.image.width / 4) + CaseStyle.iconSize,
      (imageInfo.image.height / 4) + CaseStyle.iconSize,
    );
    final offset = ui.Offset(
        imageSize!.width - itemController.config!.value.size!.width,
        imageSize!.height - itemController.config!.value.size!.height);
    itemController.setOriginalSize(imageSize!);
    itemController.resizeCase(offset);
    notifyListeners();
  }

  Future<void> _parseSvg() async {
    _maskSvg = await svg.fromSvgString(generateMaskSVG(maskSvgString!), '');
    _calculateSvgSize();
    _maskSvgOldSize = _maskSvgCurrentSize;
    _renderSvg();
  }

  bool? onSizeChanged(Size newCaseSize) {
    caseSize = Size(
      newCaseSize.width - CaseStyle.iconSize,
      newCaseSize.height - CaseStyle.iconSize,
    );
    if (_maskSvgString != null) {
      _calculateSvgSize();

      final double oldSize =
          (_maskSvgOldSize.width + _maskSvgOldSize.height) / 2;
      final double newSize =
          (_maskSvgCurrentSize.width + _maskSvgCurrentSize.height) / 2;

      if (max(newSize, oldSize) / min(newSize, oldSize) > sizeChangeTreshold) {
        _maskSvgOldSize = _maskSvgCurrentSize;
        _renderSvg();
      } else {
        _renderShader();
      }
    }
    return true;
  }

  bool? onResizeDone(ui.Size size) {
    if (_maskSvgString != null) {
      _calculateSvgSize();
      _maskSvgOldSize = _maskSvgCurrentSize;
      _renderSvg();
    }
    return true;
  }

  Future<void> _renderSvg() async {
    _maskSvgImage = await _maskSvg
        .toPicture(
          size: _maskSvgCurrentSize,
        )
        .toImage(
          _maskSvgCurrentSize.width.toInt(),
          _maskSvgCurrentSize.height.toInt(),
        );

    _renderShader();
  }

  void _calculateSvgSize() {
    _maskSvgCurrentSize = applyBoxFit(
      BoxFit.contain,
      Size(
        _maskSvg.viewport.viewBox.width,
        _maskSvg.viewport.viewBox.height,
      ),
      caseSize,
    ).destination;
  }

  void _renderShader() {
    final Size maskSize = ui.Size(
      _maskSvgImage.width.toDouble(),
      _maskSvgImage.height.toDouble(),
    );

    final ui.Offset center =
        caseSize.center(Offset.zero) - _maskSvgCurrentSize.center(Offset.zero);

    final Matrix4 matrix = Matrix4.identity()
      ..scale(
        _maskSvgCurrentSize.width / maskSize.width,
        _maskSvgCurrentSize.height / maskSize.height,
      )
      ..leftTranslate(center.dx, center.dy);

    maskShader = ImageShader(
      _maskSvgImage,
      TileMode.clamp,
      TileMode.clamp,
      matrix.storage,
    );
  }

  @override
  void dispose() {
    itemController.dispose();
    super.dispose();
  }
}
