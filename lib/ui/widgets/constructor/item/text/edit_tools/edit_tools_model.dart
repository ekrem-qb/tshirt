import 'package:flutter/cupertino.dart';

import '../text_model.dart';

class TextEditTools extends ChangeNotifier {
  TextEditTools(
    TextItem textModel,
  ) {
    _toggleButtons = [
      textModel.style.fontWeight == FontWeight.bold,
      textModel.style.fontStyle == FontStyle.italic,
      textModel.style.decoration == TextDecoration.underline,
    ];
  }

  late List<bool> _toggleButtons;

  List<bool> get toggleButtons => _toggleButtons;

  set toggleButtons(List<bool> toggleButtons) {
    _toggleButtons = toggleButtons;
    notifyListeners();
  }
}
