import 'package:flutter/material.dart';

class BrushSizeIndicator extends ChangeNotifier {
  double _value = 1;
  double get value => _value;
  set value(double indicator) {
    _value = indicator;
    notifyListeners();
  }
}
