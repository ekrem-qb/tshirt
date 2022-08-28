import 'package:flutter/material.dart';

import '../../../../../../../resources/masks.dart';
import '../../image_model.dart';

class MaskPicker extends ChangeNotifier {
  MaskPicker(this.imageModel, String? currentMask) {
    if (currentMask != null) {
      final lastSelectedIndex = masks.indexOf(currentMask);
      if (lastSelectedIndex != -1) {
        selectedIndex = lastSelectedIndex;
      }
    }
  }

  final ImageItem imageModel;

  List<String> _masks = defaultMaskPaths;
  List<String> get masks => _masks;
  set masks(List<String> masks) {
    _masks = masks;
    notifyListeners();
  }

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  set selectedIndex(int selectedIndex) {
    _selectedIndex = selectedIndex;
    notifyListeners();
  }

  final scrollController = ScrollController();
}

String generateMaskSVG(String path) {
  return path[0] == '<'
      ? path
      : '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="$path" /></svg>';
}
