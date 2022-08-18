import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stack_board/stack_board.dart';

import '../../resources/images.dart';

///自定义类型 Custom item type
class CustomItem extends StackBoardItem {
  const CustomItem({
    required this.color,
    Future<bool> Function()? onDelete,
    int? id, // <==== must
  }) : super(
          child: const Text('CustomItem'),
          onDelete: onDelete,
          id: id, // <==== must
        );

  final Color? color;

  @override // <==== must
  CustomItem copyWith({
    CaseStyle? caseStyle,
    Widget? child,
    int? id,
    Future<bool> Function()? onDelete,
    dynamic Function(bool)? onEdit,
    bool? tapToEdit,
    Color? color,
  }) =>
      CustomItem(
        onDelete: onDelete,
        id: id,
        color: color ?? this.color,
      );
}

class StackBoardScreen extends StatefulWidget {
  const StackBoardScreen({Key? key}) : super(key: key);

  @override
  _StackBoardScreenState createState() => _StackBoardScreenState();
}

class _StackBoardScreenState extends State<StackBoardScreen> {
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

  /// 删除拦截
  Future<bool> _onDel() async {
    final bool? r = await showDialog<bool>(
      context: context,
      builder: (_) {
        return Center(
          child: SizedBox(
            width: 400,
            child: Material(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 60),
                      child: Text('确认删除?'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        IconButton(
                            onPressed: () => Navigator.pop(context, true),
                            icon: const Icon(Icons.check)),
                        IconButton(
                            onPressed: () => Navigator.pop(context, false),
                            icon: const Icon(Icons.clear)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    return r ?? false;
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
                      child: const Icon(Icons.border_color),
                    ),
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
                      child: const Icon(Icons.image),
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
                      child: const Icon(Icons.color_lens),
                    ),
                    _spacer,
                    FloatingActionButton(
                      onPressed: () {
                        _boardController.add(
                          StackBoardItem(
                            child: const Text(
                              'Custom Widget',
                              style: TextStyle(color: Colors.black),
                            ),
                            onDelete: _onDel,
                            // caseStyle: const CaseStyle(initOffset: Offset(100, 100)),
                          ),
                        );
                      },
                      child: const Icon(Icons.add_box),
                    ),
                    _spacer,
                    FloatingActionButton(
                      onPressed: () {
                        _boardController.add<CustomItem>(
                          CustomItem(
                            color: Color((math.Random().nextDouble() * 0xFFFFFF)
                                    .toInt())
                                .withOpacity(1.0),
                            onDelete: () async => true,
                          ),
                        );
                      },
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ),
            FloatingActionButton(
              onPressed: () => _boardController.clear(),
              child: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _spacer => const SizedBox(width: 5);
}

class ItemCaseDemo extends StatefulWidget {
  const ItemCaseDemo({Key? key}) : super(key: key);

  @override
  _ItemCaseDemoState createState() => _ItemCaseDemoState();
}

class _ItemCaseDemoState extends State<ItemCaseDemo> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ItemCase(
          isCentered: false,
          child: const Text('Custom case'),
          onDelete: () async {},
          onOperationStateChanged: (OperationState operationState) => null,
          onOffsetChanged: (Offset offset) => null,
          onSizeChanged: (Size size) => null,
        ),
      ],
    );
  }
}
