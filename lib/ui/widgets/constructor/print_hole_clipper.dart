import 'package:flutter/material.dart';

import 'constructor_model.dart';

class PrintHoleClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(
      printOffset.dx,
      printOffset.dy,
      printSize.width,
      printSize.height,
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false;
  }
}
