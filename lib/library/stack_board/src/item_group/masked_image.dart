import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../ui/widgets/image_choose.dart';
import '../../../image_provider_extension/image_provider_extension.dart';
import '../../../modal_top_sheet/modal_top_sheet.dart';
import '../case_group/item_case.dart';
import '../helper/case_style.dart';
import 'stack_board_item.dart';

/// 自适应文本
class MaskedImage extends StackBoardItem with ChangeNotifier {
  MaskedImage(
    this._image, {
    super.id,
    super.onDelete,
    super.caseStyle,
    bool? tapToEdit,
  }) : super(
          child: const SizedBox.shrink(),
          tapToEdit: tapToEdit ?? false,
        );

  @override
  MaskedImage copyWith({
    ImageProvider? image,
    String? mask,
    int? id,
    Widget? child,
    Function(bool)? onEdit,
    Future<bool> Function()? onDelete,
    CaseStyle? caseStyle,
    bool? tapToEdit,
  }) {
    return MaskedImage(
      image ?? this.image,
      id: id ?? this.id,
      onDelete: onDelete ?? this.onDelete,
      caseStyle: caseStyle ?? this.caseStyle,
      tapToEdit: tapToEdit ?? this.tapToEdit,
    );
  }

  static const Size defaultSize = Size(100, 100);
  static const double sizeChangeTreshold = 1.5;

  Size caseSize = defaultSize;
  final ItemCaseController caseController = ItemCaseController();

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

  void calculateImageSize() async {
    final imageInfo = await image.getImageInfo();
    imageSize = ui.Size(
      (imageInfo.image.width / 4) + (caseStyle?.iconSize ?? 24),
      (imageInfo.image.height / 4) + (caseStyle?.iconSize ?? 24),
    );
    final offset = ui.Offset(
        imageSize!.width - caseController.config!.value.size!.width,
        imageSize!.height - caseController.config!.value.size!.height);
    caseController.setOriginalSize(imageSize!);
    caseController.resizeCase(offset);
    notifyListeners();
  }

  Future<void> _parseSvg() async {
    _maskSvg = await svg.fromSvgString(maskSvgString!, '');
    _calculateSvgSize();
    _maskSvgOldSize = _maskSvgCurrentSize;
    _renderSvg();
  }

  bool? onSizeChanged(Size newCaseSize) {
    caseSize = Size(
      newCaseSize.width - (caseStyle?.iconSize ?? 24),
      newCaseSize.height - (caseStyle?.iconSize ?? 24),
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

  bool? onFlipped(Matrix4 newFlipMatrix) {
    flipMatrix = Matrix4.fromFloat64List(newFlipMatrix.storage);
    return true;
  }

  void chooseMask(BuildContext context) async {
    await showModalTopSheet(
      context: context,
      child: Center(
        child: Wrap(
          spacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: _pickSvgString,
              icon: const Icon(Icons.file_open_rounded),
              label: const Text('File'),
            ),
            ElevatedButton.icon(
              onPressed: () => maskSvgString = null,
              icon: const Icon(Icons.not_interested_rounded),
              label: const Text('None'),
            ),
          ],
        ),
      ),
    );
  }

  void _pickSvgString() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['svg'],
    );
    if (result != null) {
      final file = File(result.files.single.path!);
      maskSvgString = await file.readAsString();
    }
  }

  void chooseImage(BuildContext context) async {
    final result = await showModalTopSheet<ImageProvider>(
      context: context,
      child: imageChooseWidget(context),
    );
    if (result != null) {
      image = result;
    }
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
}
