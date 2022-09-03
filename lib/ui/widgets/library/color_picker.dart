import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class ColorPickerWidget extends StatelessWidget {
  const ColorPickerWidget({
    super.key,
    this.color = Colors.blue,
    required this.onColorChanged,
  });

  final Color color;
  final Function(Color) onColorChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(
        height: 432,
      ),
      child: ColorPicker(
        hasBorder: true,
        wheelHasBorder: true,
        colorCodeHasColor: true,
        enableOpacity: true,
        subheading: const Text('Color shade'),
        wheelSubheading: const Text('Color shade'),
        opacitySubheading: const Text('Opacity'),
        pickersEnabled: const {
          ColorPickerType.primary: true,
          ColorPickerType.accent: false,
          ColorPickerType.wheel: true,
        },
        color: color,
        onColorChanged: onColorChanged,
      ),
    );
  }
}
