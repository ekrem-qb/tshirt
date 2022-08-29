import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import 'board/board_widget.dart';

const tshirtSize = Size(671, 675);
const printSize = Size(297, 210);
const printOffset = Offset(0, -105);

class Constructor extends ChangeNotifier {
  Constructor() {
    loadPrintMaskShader();
  }

  final boardController = StackBoardController();
  Shader? _printMaskShader;
  Shader? get printMaskShader => _printMaskShader;
  set printMaskShader(Shader? printMaskShader) {
    _printMaskShader = printMaskShader;
    notifyListeners();
  }

  void loadPrintMaskShader() async {
    final svgRoot = await svg.fromSvgString('''
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg viewBox="0 0 ${tshirtSize.width} ${tshirtSize.height}">
    <rect x="187.5" y="127.19" width="297" height="210"/>
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
