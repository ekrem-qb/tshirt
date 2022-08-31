import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../../domain/entity/tshirt.dart';
import '../../../resources/images.dart';
import '../../theme.dart';
import '../library/modal_sheet.dart';
import '../preview/preview_widget.dart';
import 'board/board_widget.dart';
import 'constructor_model.dart';
import 'item/image/edit_tools/image_picker/image_picker_widget.dart';
import 'item/image/image_model.dart';
import 'item/paint/paint_model.dart';
import 'item/text/text_model.dart';

class ConstructorScreen extends StatelessWidget {
  const ConstructorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Constructor(),
      child: const _ConstructorWidget(),
    );
  }
}

class _ConstructorWidget extends StatelessWidget {
  const _ConstructorWidget();

  @override
  Widget build(BuildContext context) {
    final constructorModel = context.read<Constructor>();

    return Listener(
      onPointerDown: (_) {
        constructorModel.boardController.unFocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Custom Design Constructor'),
          actions: [
            _PrintButton(constructorModel: constructorModel),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: const [
            _TshirtWidget(),
            _TopSheet(),
            _BorderWidget(),
            _BoardWidget(),
          ],
        ),
        bottomSheet: const _BottomSheet(),
      ),
    );
  }
}

class _PrintButton extends StatelessWidget {
  const _PrintButton({
    Key? key,
    required this.constructorModel,
  }) : super(key: key);

  final Constructor constructorModel;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ButtonStyle(
        elevation: MaterialStateProperty.all<double>(0),
      ),
      onPressed: () async {
        final pixelRatio = MediaQuery.of(context).devicePixelRatio;

        final image = await constructorModel.screenshotController
            .capture(delay: Duration.zero);

        final croppedImage =
            await constructorModel.screenshotController.captureFromWidget(
          SizedBox(
            width: printSize.width / pixelRatio,
            height: printSize.height / pixelRatio,
            child: FittedBox(
              fit: BoxFit.none,
              clipBehavior: Clip.hardEdge,
              child: Transform.translate(
                offset: -printOffsetFromCenter / pixelRatio,
                child: SizedBox.fromSize(
                  size: tshirtSize / pixelRatio,
                  child: Image.memory(
                    image!,
                  ),
                ),
              ),
            ),
          ),
          delay: const Duration(milliseconds: 100),
        );

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return PreviewScreen(
                Tshirt(
                  name: 'Custom Design',
                  print: croppedImage,
                ),
                isFlipped: constructorModel.isTshirtFlipped,
              );
            },
          ),
        );
      },
      icon: const Icon(Icons.print_rounded),
      label: const Text('Print'),
    );
  }
}

class _TopSheet extends StatelessWidget {
  const _TopSheet();

  @override
  Widget build(BuildContext context) {
    final constructorModel = context.read<Constructor>();

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(buttonsSpacing),
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 15,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    constructorModel.boardController.clear();
                  },
                  icon: const Icon(Icons.delete_rounded),
                  label: const Text('Clear'),
                ),
              ),
              const SizedBox(width: buttonsSpacing),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    constructorModel.isTshirtFlipped =
                        !constructorModel.isTshirtFlipped;
                  },
                  icon: const Icon(Icons.flip),
                  label: const Text('Flip'),
                ),
              ),
            ],
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
    final isTshirtFlipped =
        context.select((Constructor model) => model.isTshirtFlipped);

    return Positioned(
      width: tshirtSize.width,
      height: tshirtSize.height,
      child: Image(
        image: isTshirtFlipped ? Images.tshirtBack : Images.tshirtFront,
      ),
    );
  }
}

class _BoardWidget extends StatelessWidget {
  const _BoardWidget();

  @override
  Widget build(BuildContext context) {
    final constructorModel = context.read<Constructor>();

    return Positioned(
      width: tshirtSize.width,
      height: tshirtSize.height,
      child: Screenshot(
        controller: constructorModel.screenshotController,
        child: BoardWidget(controller: constructorModel.boardController),
      ),
    );
  }
}

class _BorderWidget extends StatelessWidget {
  const _BorderWidget();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: printSize.width,
      height: printSize.height,
      child: Transform.translate(
        offset: printOffsetFromCenter,
        child: DottedBorder(
          color: Colors.grey,
          strokeCap: StrokeCap.square,
          strokeWidth: 2,
          dashPattern: const [8],
          child: const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  const _BottomSheet();

  @override
  Widget build(BuildContext context) {
    final constructorModel = context.read<Constructor>();

    return Padding(
      padding: const EdgeInsets.all(buttonsSpacing),
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 15,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  constructorModel.boardController.add(
                    TextItem('Text'),
                  );
                },
                icon: const Icon(Icons.text_fields_rounded),
                label: const Text('Text'),
              ),
            ),
            const SizedBox(width: buttonsSpacing),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await showModal<ImageProvider>(
                    context: context,
                    dimBackground: true,
                    child: const ImagePickerWidget(),
                  );
                  if (result != null) {
                    constructorModel.boardController.add(
                      ImageItem(result),
                    );
                  }
                },
                icon: const Icon(Icons.image_rounded),
                label: const Text('Image'),
              ),
            ),
            const SizedBox(width: buttonsSpacing),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  constructorModel.boardController.add(
                    PaintItem(),
                  );
                },
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Paint'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
