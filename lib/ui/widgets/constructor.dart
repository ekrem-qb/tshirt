import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:stack_board/stack_board.dart';

import '../../resources/images.dart';

class ConstructorScreen extends StatefulWidget {
  const ConstructorScreen({Key? key}) : super(key: key);

  @override
  ConstructorScreenState createState() => ConstructorScreenState();
}

class ConstructorScreenState extends State<ConstructorScreen> {
  late StackBoardController _boardController;

  void _pickupFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      final file = File(result.files.single.path!);
      _boardController.add(
        MaskedImage(
          FileImage(file),
        ),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _boardController = StackBoardController();
  }

  @override
  void dispose() {
    _boardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        _boardController.unFocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Stack Board Demo'),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(
              top: 265 / 8,
              width: 671 * 2,
              height: 675 * 2,
              child: Image(
                image: Images.tshirtFront,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              width: 297 * 2,
              height: 210 * 2,
              child: ClipRect(
                child: StackBoard(
                  controller: _boardController,
                  caseStyle: const CaseStyle(
                    borderColor: Colors.grey,
                    iconColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    const SizedBox(width: 25),
                    FloatingActionButton(
                        onPressed: () {
                          _boardController.add(
                            const AdaptiveText(
                              'Flutter Candies',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                        child: const Icon(Icons.text_fields_rounded)),
                    _spacer,
                    FloatingActionButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Center(
                              child: ElevatedButton.icon(
                                onPressed: () => _pickupFile(context),
                                icon: const Icon(Icons.file_open_rounded),
                                label: const Text('File'),
                              ),
                            );
                          },
                        );
                      },
                      child: const Icon(Icons.image_rounded),
                    ),
                    _spacer,
                    FloatingActionButton(
                        onPressed: () {
                          _boardController.add(
                            const StackDrawing(
                              caseStyle: CaseStyle(
                                borderColor: Colors.grey,
                                iconColor: Colors.white,
                              ),
                            ),
                          );
                        },
                        child: const Icon(Icons.edit_rounded)),
                    _spacer,
                  ],
                ),
              ),
            ),
            FloatingActionButton(
              onPressed: () => _boardController.clear(),
              child: const Icon(Icons.delete_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _spacer => const SizedBox(width: 5);
}
