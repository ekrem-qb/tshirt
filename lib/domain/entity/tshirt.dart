import 'dart:typed_data';

class Tshirt {
  Tshirt({
    required this.name,
    required this.print,
  });

  final String name;
  final Uint8List print;
}
