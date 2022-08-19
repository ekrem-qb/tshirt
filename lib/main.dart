import 'package:flutter/material.dart';
import 'ui/widgets/constructor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      theme: ThemeData(
        brightness:
            WidgetsBinding.instance.platformDispatcher.platformBrightness,
      ),
      home: const ConstructorScreen(),
    ),
  );
}
