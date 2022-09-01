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
        constructorModel.boardController.focus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Custom Design Constructor'),
          actions: const [
            _PrintButton(),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: const [
            _TshirtWidget(),
            _FlipButton(),
            _BorderWidget(),
            _BoardWidget(),
          ],
        ),
        bottomSheet: const _BottomSheet(),
      ),
    );
  }
}

class _FlipButton extends StatelessWidget {
  const _FlipButton();

  @override
  Widget build(BuildContext context) {
    final constructorModel = context.read<Constructor>();

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(buttonsSpacing),
        child: FloatingActionButton.extended(
          label: const Text('Flip Side'),
          icon: const Icon(Icons.rotate_left),
          onPressed: () => constructorModel.isTshirtFlipped =
              !constructorModel.isTshirtFlipped,
        ),
      ),
    );
  }
}

class _PrintButton extends StatelessWidget {
  const _PrintButton();

  @override
  Widget build(BuildContext context) {
    final constructorModel = context.read<Constructor>();

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
        height: 150,
        child: Column(
          children: [
            Expanded(
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
            const SizedBox(height: buttonsSpacing),
            Expanded(
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
                        showModal(
                          context: context,
                          child: _LayersListWidget(
                            boardController: constructorModel.boardController,
                          ),
                        );
                      },
                      icon: const Icon(Icons.layers_rounded),
                      label: const Text('Layers'),
                    ),
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

class _LayersListWidget extends StatefulWidget {
  const _LayersListWidget({required this.boardController});

  final StackBoardController boardController;

  @override
  State<_LayersListWidget> createState() => _LayersListWidgetState();
}

class _LayersListWidgetState extends State<_LayersListWidget> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 500,
        minHeight: 180,
      ),
      child: Center(
        heightFactor: 1,
        child: ReorderableListView.builder(
          shrinkWrap: true,
          buildDefaultDragHandles: false,
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final reversedOldIndex =
                (widget.boardController.items.length - 1) - oldIndex;
            final reversedNewIndex =
                (widget.boardController.items.length - 1) - newIndex;
            widget.boardController
                .reorderItem(reversedOldIndex, reversedNewIndex);
            setState(() {});
          },
          itemCount: widget.boardController.items.length,
          itemBuilder: (context, index) {
            final reversedIndex =
                (widget.boardController.items.length - 1) - index;
            final item = widget.boardController.items[reversedIndex];

            return ReorderableDelayedDragStartListener(
              key: Key('$index'),
              index: index,
              child: ListTile(
                leading: Icon(
                  item is ImageItem
                      ? Icons.image_rounded
                      : item is TextItem
                          ? Icons.text_fields_rounded
                          : item is PaintItem
                              ? Icons.edit_rounded
                              : Icons.layers_rounded,
                ),
                title: Text(
                  item is ImageItem
                      ? 'Image'
                      : item is TextItem
                          ? item.text
                          : item is PaintItem
                              ? 'Paint'
                              : 'Layer',
                ),
                trailing: IconButton(
                  splashColor: Colors.red,
                  onPressed: () {
                    widget.boardController.remove(item.id);
                    setState(() {});
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
                onTap: () => widget.boardController.focus(item.id),
              ),
            );
          },
        ),
      ),
    );
  }
}
