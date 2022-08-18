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
        body: Center(
          child: SizedBox(
            width: 671,
            height: 675,
            child: Stack(
              children: <Widget>[
                const Image(
                  image: Images.tshirtFront,
                  width: 671,
                  height: 675,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: (675 / 2) - (210 / 2) - 105,
                  left: (671 / 2) - (297 / 2),
                  width: 297,
                  height: 210,
                  child: StackBoard(
                    controller: _boardController,
                    caseStyle: const CaseStyle(
                      borderColor: Colors.grey,
                      iconColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                        _boardController.add(
                          const MaskedImage(
                            NetworkImage(
                                'https://uprostim.com/wp-content/uploads/2021/05/image034-5.jpg'),
                          ),
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
