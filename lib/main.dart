import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'ui/widgets/constructor/constructor_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      theme: ThemeData(
        brightness:
            WidgetsBinding.instance.platformDispatcher.platformBrightness,
      ),
      home: const ConstructorScreen(),
    ),
  );
}
