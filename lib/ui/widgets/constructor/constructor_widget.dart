import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../resources/images.dart';
import '../library/modal_sheet.dart';
import 'board/board_widget.dart';
import 'constructor_model.dart';
import 'item/image/edit_tools/image_picker/image_picker_widget.dart';
import 'item/image/image_model.dart';
import 'item/paint/paint_model.dart';
import 'item/text/text_model.dart';

const buttonsSpacing = 16.0;

class ConstructorScreen extends StatelessWidget {
  const ConstructorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => Constructor(), child: const _ConstructorWidget());
  }
}

class _ConstructorWidget extends StatelessWidget {
  const _ConstructorWidget();

  @override
  Widget build(BuildContext context) {
    final boardController = context.read<Constructor>().boardController;

    return Listener(
      onPointerDown: (_) {
        boardController.unFocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(buttonsSpacing),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 10,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).maybePop();
                                },
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: const Text('Back'),
                              ),
                            ),
                            // const SizedBox(width: buttonsSpacing),
                            // Expanded(
                            //   child: ElevatedButton.icon(
                            //     onPressed: () {},
                            //     icon: const Icon(Icons.print_rounded),
                            //     label: const Text('Print'),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      const SizedBox(height: buttonsSpacing),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => boardController.clear(),
                                icon: const Icon(Icons.delete_rounded),
                                label: const Text('Clear'),
                              ),
                            ),
                            // const SizedBox(width: buttonsSpacing),
                            // Expanded(
                            //   child: ElevatedButton.icon(
                            //     onPressed: () {},
                            //     icon: const Icon(Icons.flip),
                            //     label: const Text('Flip'),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              width: tshirtSize.width,
              height: tshirtSize.height,
              child: Stack(
                children: const [
                  Image(image: Images.tshirtFront),
                  _BoardWidget(),
                ],
              ),
            ),
          ],
        ),
        bottomSheet: Padding(
          padding: const EdgeInsets.all(buttonsSpacing),
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 15,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      boardController.add(
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
                        boardController.add(
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
                      boardController.add(
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
        ),
      ),
    );
  }
}

class _BoardWidget extends StatelessWidget {
  const _BoardWidget();

  @override
  Widget build(BuildContext context) {
    final boardController = context.read<Constructor>().boardController;
    final printMaskShader =
        context.select((Constructor model) => model.printMaskShader);

    return printMaskShader != null
        ? ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (_) => printMaskShader,
            child: BoardWidget(controller: boardController),
          )
        : BoardWidget(controller: boardController);
  }
}
