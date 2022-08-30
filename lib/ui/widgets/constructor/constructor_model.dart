import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:screenshot/screenshot.dart';

import '../../theme.dart';
import 'board/board_widget.dart';

class Constructor extends ChangeNotifier {
  Constructor() {
    loadPrintMaskShader();
  }

  final boardController = StackBoardController();
  final screenshotController = ScreenshotController();

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
    boardController.printMaskShader = ImageShader(
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
