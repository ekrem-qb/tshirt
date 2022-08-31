import 'package:flutter/material.dart';

import '../../../domain/entity/tshirt.dart';

class Preview extends ChangeNotifier {
  Preview(bool isFlipped)
      : _side = isFlipped ? TshirtSide.Back : TshirtSide.Front,
        _sideToggles = isFlipped ? [false, true] : [true, false];

  TshirtSize size = TshirtSize.M;

  List<bool> _sizeToggles = [false, true, false];
  List<bool> get sizeToggles => _sizeToggles;
  set sizeToggles(List<bool> sizeToggles) {
    _sizeToggles = sizeToggles;
    if (_sizeToggles[0]) {
      size = TshirtSize.S;
    } else if (_sizeToggles[1]) {
      size = TshirtSize.M;
    } else {
      size = TshirtSize.L;
    }
    notifyListeners();
  }

  TshirtSide _side;
  TshirtSide get side => _side;
  set side(TshirtSide side) {
    _side = side;
    notifyListeners();
  }

  List<bool> _sideToggles;
  List<bool> get sideToggles => _sideToggles;
  set sideToggles(List<bool> sideToggles) {
    _sideToggles = sideToggles;
    if (sideToggles[0]) {
      side = TshirtSide.Front;
    } else {
      side = TshirtSide.Back;
    }
    notifyListeners();
  }
}
