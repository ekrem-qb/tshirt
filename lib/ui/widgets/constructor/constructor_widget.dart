import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../../domain/entity/tshirt.dart';
import '../../../resources/images.dart';
import '../../theme.dart';
import '../library/center_guides.dart';
import '../library/modal_sheet.dart';
import '../preview/preview_widget.dart';
import 'constructor_model.dart';
import 'item/image/edit_tools/image_picker/image_picker_widget.dart';
import 'item/image/image_model.dart';
import 'item/image/image_widget.dart';
import 'item/item_model.dart';
import 'item/item_widget.dart';
import 'item/paint/paint_model.dart';
import 'item/paint/paint_widget.dart';
import 'item/text/text_model.dart';
import 'item/text/text_widget.dart';

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
        constructorModel.unfocus();
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
                  print: MemoryImage(croppedImage),
                )..id = '',
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
    final constructorModel = context.watch<Constructor>();

    return Positioned(
      width: tshirtSize.width,
      height: tshirtSize.height,
      child: Screenshot(
        controller: constructorModel.screenshotController,
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ...constructorModel.items
                  .map((Item item) => _buildItem(item, constructorModel))
                  .toList(),
              CenterGuides(
                controller: constructorModel.centerGuidesController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildItem(Item item, Constructor constructorModel) {
  if (item is TextItem) {
    return TextItemWidget(
      key: Key('${item.id}'),
      text: item.text,
      onDelete: () => constructorModel.onDelete(item),
      onPointerDown: () => constructorModel.focus(item.id),
      operationState: constructorModel.focusedItemId == item.id
          ? OperationState.idle
          : OperationState.complete,
    );
  }
  if (item is PaintItem) {
    return PaintItemWidget(
      key: Key('${item.id}'),
      onDelete: () => constructorModel.onDelete(item),
      onPointerDown: () => constructorModel.focus(item.id),
      operationState: constructorModel.focusedItemId == item.id
          ? OperationState.idle
          : OperationState.complete,
    );
  }
  if (item is ImageItem) {
    return ImageItemWidget(
      key: Key('${item.id}'),
      image: item.image,
      onDelete: () => constructorModel.onDelete(item),
      onPointerDown: () => constructorModel.focus(item.id),
      operationState: constructorModel.focusedItemId == item.id
          ? OperationState.idle
          : OperationState.complete,
    );
  }
  return ItemWidget(
    key: Key('${item.id}'),
    onDelete: () => constructorModel.onDelete(item),
    onPointerDown: () => constructorModel.focus(item.id),
    operationState: constructorModel.focusedItemId == item.id
        ? OperationState.idle
        : OperationState.complete,
    child: item.child,
  );
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
        height: modalSheetHeight,
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        constructorModel.add(
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
                          constructorModel.add(
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
                        constructorModel.add(
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
                        constructorModel.clear();
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
                            constructorModel: constructorModel,
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
  const _LayersListWidget({required this.constructorModel});

  final Constructor constructorModel;

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
        child: widget.constructorModel.items.isNotEmpty
            ? ReorderableListView.builder(
                shrinkWrap: true,
                buildDefaultDragHandles: false,
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final reversedOldIndex =
                      (widget.constructorModel.items.length - 1) - oldIndex;
                  final reversedNewIndex =
                      (widget.constructorModel.items.length - 1) - newIndex;
                  widget.constructorModel
                      .reorderItem(reversedOldIndex, reversedNewIndex);
                  setState(() {});
                },
                itemCount: widget.constructorModel.items.length,
                itemBuilder: (context, index) {
                  final reversedIndex =
                      (widget.constructorModel.items.length - 1) - index;
                  final item = widget.constructorModel.items[reversedIndex];

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
                          widget.constructorModel.remove(item.id);
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                      onTap: () => widget.constructorModel.focus(item.id),
                    ),
                  );
                },
              )
            : const Text('Add some text, image or paint layer'),
      ),
    );
  }
}
