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

  bool _isEmpty = true;
  bool get isEmpty => _isEmpty;
  set isEmpty(bool isEmpty) {
    _isEmpty = isEmpty;
    notifyListeners();
  }

  List<Item> items = [];

  int? focusedItemId;

  int lastId = 0;

  OperationState? operationState;

  final CenterGuidesController centerGuidesController =
      CenterGuidesController();

  void add<T extends Item>(Item item) {
    if (items.contains(item)) throw 'duplicate id';

    items.add(item.copyWith(
      id: item.id ?? lastId,
    ));

    lastId++;

    focus(items.last.id);
  }

  void remove(int? id) {
    items.removeWhere((Item b) => b.id == id);
    notifyListeners();
  }

  void clear() {
    items.clear();
    lastId = 0;
    notifyListeners();
  }

  void focus(int? id) {
    if (focusedItemId == null) {
      focusedItemId = id;
      operationState = OperationState.complete;
      notifyListeners();
    }
  }

  void unfocus() {
    notifyListeners();
  }

  Future<void> onDelete(Item box) async {
    final bool delete = (await box.onDelete?.call()) ?? true;
    if (delete) remove(box.id);
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
