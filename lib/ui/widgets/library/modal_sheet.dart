import 'package:flutter/material.dart';

Future<T?> showModal<T>({
  required BuildContext context,
  required Widget child,
  bool dimBackground = false,
}) {
  return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: dimBackground ? Colors.black54 : Colors.transparent,
      pageBuilder: (context, _, __) {
        return Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Material(
              elevation: 64,
              type: MaterialType.card,
              child: child,
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ).drive(Tween<Offset>(
            // begin: const Offset(0, -1.0),
            begin: const Offset(0, 1.0),
            end: Offset.zero,
          )),
          child: child,
        );
      });
}
