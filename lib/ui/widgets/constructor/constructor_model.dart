import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:screenshot/screenshot.dart';

import 'board/board_widget.dart';

const tshirtSize = Size(671, 675);
const printSize = Size(297, 210);
const printOffset = Offset(187.5, 127.19);
const printOffsetFromCenter = Offset(0, -105);

class Constructor extends ChangeNotifier {
  Constructor() {
    loadPrintMaskShader();
  }

  final boardController = StackBoardController();
  final screenshotController = ScreenshotController();

  bool _isPrinting = false;
  bool get isPrinting => _isPrinting;
  set isPrinting(bool isPrinting) {
    _isPrinting = isPrinting;
    notifyListeners();
  }

  Shader? _printMaskShader;
  Shader? get printMaskShader => _printMaskShader;
  set printMaskShader(Shader? printMaskShader) {
    _printMaskShader = printMaskShader;
    notifyListeners();
  }

  bool _isTshirtFlipped = false;
  bool get isTshirtFlipped => _isTshirtFlipped;
  set isTshirtFlipped(bool isTshirtFlipped) {
    _isTshirtFlipped = isTshirtFlipped;
    notifyListeners();
  }

  void loadPrintMaskShader() async {
    final svgRoot = await svg.fromSvgString('''
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg viewBox="0 0 ${tshirtSize.width} ${tshirtSize.height}">
    <rect x="${printOffset.dx}" y="${printOffset.dy}" width="${printSize.width}" height="${printSize.height}"/>
    <rect width="${tshirtSize.width}" height="${tshirtSize.height}" style="fill-opacity:0.25;"/>
</svg>
''', '');
    final svgImage = await svgRoot
        .toPicture(size: tshirtSize)
        .toImage(tshirtSize.width.toInt(), tshirtSize.height.toInt());
    printMaskShader = ImageShader(
      svgImage,
      TileMode.decal,
      TileMode.decal,
      Matrix4.identity().storage,
    );
  }

  @override
  void dispose() {
    boardController.dispose();
    super.dispose();
  }
}
