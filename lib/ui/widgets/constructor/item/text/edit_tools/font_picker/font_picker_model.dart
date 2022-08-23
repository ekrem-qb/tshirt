import 'package:flutter/cupertino.dart';

import '../../text_model.dart';

class FontPicker extends ChangeNotifier {
  FontPicker(this.textModel, String currentFont) {
    final lastSelectedIndex = fonts.indexOf(currentFont);
    if (lastSelectedIndex != -1) {
      selectedIndex = lastSelectedIndex;
    }
  }

  final TextItem textModel;

  List<String> _fonts = [
    'Roboto',
    'Raleway',
    'Rubik',
    'Lora',
    'Josefin Sans',
    'Bebas Neue',
    'Dancing Script',
    'Anton',
    'Lobster',
    'Pacifico',
    'Rajdhani',
    'Abril Fatface',
    'Shadows Into Light',
    'Permanent Marker',
    'Satisfy',
  ];

  List<String> get fonts => _fonts;

  set fonts(List<String> fonts) {
    _fonts = fonts;
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
