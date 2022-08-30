import 'package:flutter/cupertino.dart';

class Preview extends ChangeNotifier {
  Preview(this._isFlipped);

  bool _isFlipped;
  bool get isFlipped => _isFlipped;
  set isFlipped(bool isFlipped) {
    _isFlipped = isFlipped;
    notifyListeners();
  }
}
