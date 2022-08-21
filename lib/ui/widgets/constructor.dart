import 'package:flutter/material.dart';

import '../../library/stack_board/stack_board.dart';
import '../../resources/images.dart';
import 'image_choose.dart';

class ConstructorScreen extends StatefulWidget {
  const ConstructorScreen({super.key});

  @override
  ConstructorScreenState createState() => ConstructorScreenState();
}

class ConstructorScreenState extends State<ConstructorScreen> {
  late StackBoardController _boardController;

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
            Positioned(
              width: 671 * 2,
              height: 675 * 2,
              child: Transform.translate(
                offset: const Offset(0, 105 * 2),
                child: const Image(
                  image: Images.tshirtFront,
                  fit: BoxFit.cover,
                ),
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
                      onPressed: () async {
                        final result =
                            await showModalBottomSheet<ImageProvider>(
                          context: context,
                          builder: imageChooseWidget,
                        );
                        if (result != null) {
                          _boardController.add(
                            MaskedImage(
                              result,
                            ),
                          );
                        }
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
