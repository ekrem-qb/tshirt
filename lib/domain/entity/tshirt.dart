import 'package:flutter/material.dart';

class Tshirt {
  Tshirt({
    required this.name,
    required this.print,
  });

  final String name;
  final ImageProvider print;
}

enum TshirtSize {
  S,
  M,
  L,
}

enum TshirtSide {
  Front,
  Back,
}
