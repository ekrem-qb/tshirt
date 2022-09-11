import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'domain/api/firebase.dart';
import 'ui/widgets/catalog/catalog_widget.dart';

void main() async {
  await setupFirebase();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const CupertinoScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      home: const CatalogScreen(),
    ),
  );
}
