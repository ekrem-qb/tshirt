import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:screenshot/screenshot.dart';

import '../../theme.dart';
import '../library/center_guides.dart';
import 'item/item_model.dart';

class Constructor extends ChangeNotifier {
  Constructor() {
    loadPrintMaskShader();
  }

  late ImageShader printMaskShader;

  final screenshotController = ScreenshotController();

  bool _isTshirtFlipped = false;
  bool get isTshirtFlipped => _isTshirtFlipped;
  set isTshirtFlipped(bool isTshirtFlipped) {
    _isTshirtFlipped = isTshirtFlipped;
    notifyListeners();
  }

  int? _focusedItemId;
  int? get focusedItemId => _focusedItemId;
  set focusedItemId(int? focusedItemId) {
    if (_focusedItemId != focusedItemId) {
      _focusedItemId = focusedItemId;
      notifyListeners();
    }
  }

  List<Item> items = [];

  bool _ignoreUnfocus = false;

  final CenterGuidesController centerGuidesController =
      CenterGuidesController();

  void add<T extends Item>(Item item) {
    if (items.contains(item)) throw 'duplicate id';

    items.add(item.copyWith(
      id: item.id ?? items.length,
    ));
    notifyListeners();

    focus(items.last.id);
  }

  void remove(int? id) {
    items.removeWhere((Item b) => b.id == id);
    notifyListeners();
  }

  void clear() {
    items.clear();
    notifyListeners();
  }

  void focus(int? id) {
    focusedItemId = id;
    _ignoreUnfocus = true;
  }

  void unfocus() {
    if (!_ignoreUnfocus) {
      focusedItemId = null;
    } else {
      _ignoreUnfocus = false;
    }
  }

  Future<void> onDelete(Item item) async {
    final bool delete = (await item.onDelete?.call()) ?? true;
    if (delete) remove(item.id);
  }

  void toggleCenterGuides({bool? newVerticalState, bool? newHorizontalState}) =>
      centerGuidesController.toggleGuides(
        newVerticalState: newVerticalState,
        newHorizontalState: newHorizontalState,
      );

  void reorderItem(int oldIndex, int newIndex) {
    final item = items[oldIndex];
    items.removeAt(oldIndex);
    items.insert(newIndex, item);
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
    centerGuidesController.dispose();
    super.dispose();
  }
}
