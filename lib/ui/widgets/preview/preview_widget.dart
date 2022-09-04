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
        body: Column(
          children: [
            Expanded(
              child: TshirtPreviewWidget(tshirt: tshirt),
            ),
            const _BottomSheet(),
          ],
        ),
      ),
    );
  }
}

class TshirtPreviewWidget extends StatelessWidget {
  const TshirtPreviewWidget({
    super.key,
    required this.tshirt,
  });

  final Tshirt tshirt;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tshirt.id,
      child: Center(
        child: FittedBox(
          child: SizedBox(
            width: tshirtSize.width,
            height: tshirtSize.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const _TshirtWidget(),
                Transform.translate(
                  offset: printOffsetFromCenter,
                  child: Image(
                    image: tshirt.print,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TshirtWidget extends StatelessWidget {
  const _TshirtWidget();

  @override
  Widget build(BuildContext context) {
    final side = context.select((Preview? model) => model?.side);

    return Image(
      image: side == TshirtSide.Back ? Images.tshirtBack : Images.tshirtFront,
    );
  }
}

class _BottomSheet extends StatelessWidget {
  const _BottomSheet();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(buttonsSpacing),
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 7,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Column(
                  children: const [
                    Expanded(
                      child: _SidePickerWidget(),
                    ),
                    SizedBox(height: buttonsSpacing),
                    Expanded(
                      child: _SizePickerWidget(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Expanded(
                      child: FittedBox(
                        child: Text(
                          '100₺',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: buttonsSpacing),
                    Expanded(
                      child: FittedBox(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.payment_rounded),
                          label: const Text('Pay'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidePickerWidget extends StatelessWidget {
  const _SidePickerWidget();

  @override
  Widget build(BuildContext context) {
    final previewModel = context.watch<Preview>();

    return FittedBox(
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(8),
        isSelected: previewModel.sideToggles,
        onPressed: (index) {
          for (int buttonIndex = 0;
              buttonIndex < previewModel.sideToggles.length;
              buttonIndex++) {
            if (buttonIndex == index) {
              previewModel.sideToggles[buttonIndex] = true;
            } else {
              previewModel.sideToggles[buttonIndex] = false;
            }
            previewModel.sideToggles = previewModel.sideToggles;
          }
        },
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Row(
              children: const [
                Icon(Icons.emoji_emotions_rounded),
                Text('Front'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Row(
              children: const [
                Icon(Icons.circle_rounded),
                Text('Back'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SizePickerWidget extends StatelessWidget {
  const _SizePickerWidget();

  @override
  Widget build(BuildContext context) {
    final previewModel = context.watch<Preview>();

    return FittedBox(
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(8),
        isSelected: previewModel.sizeToggles,
        onPressed: (index) {
          for (int buttonIndex = 0;
              buttonIndex < previewModel.sizeToggles.length;
              buttonIndex++) {
            if (buttonIndex == index) {
              previewModel.sizeToggles[buttonIndex] = true;
            } else {
              previewModel.sizeToggles[buttonIndex] = false;
            }
            previewModel.sizeToggles = previewModel.sizeToggles;
          }
        },
        children: const [
          Text('S'),
          Text('M'),
          Text('L'),
        ],
      ),
    );
  }
}
