import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entity/tshirt.dart';
import '../../../resources/images.dart';
import '../../theme.dart';
import 'preview_model.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen(
    this.tshirt, {
    super.key,
    this.isFlipped = false,
  });

  final Tshirt tshirt;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Preview(isFlipped),
      child: Scaffold(
        appBar: AppBar(
          title: Text(tshirt.name),
        ),
        body: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            Positioned(
              width: tshirtSize.width,
              height: tshirtSize.height,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const _TshirtWidget(),
                  Transform.translate(
                    offset: printOffsetFromCenter,
                    child: Image.memory(tshirt.print),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TshirtWidget extends StatelessWidget {
  const _TshirtWidget();

  @override
  Widget build(BuildContext context) {
    final isFlipped = context.select((Preview model) => model.isFlipped);

    return Image(
      image: isFlipped ? Images.tshirtBack : Images.tshirtFront,
    );
  }
}
