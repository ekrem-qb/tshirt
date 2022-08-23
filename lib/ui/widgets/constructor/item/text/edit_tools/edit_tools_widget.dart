import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../text_model.dart';
import 'edit_tools_model.dart';

class TextEditToolsWidget extends StatelessWidget {
  const TextEditToolsWidget({
    super.key,
    required this.textModel,
  });

  final TextItem textModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TextEditTools(textModel),
      child: Wrap(
        children: [
          _FontStyleWidget(textModel),
        ],
      ),
    );
  }
}

class _FontStyleWidget extends StatelessWidget {
  const _FontStyleWidget(this.textModel);

  final TextItem textModel;

  @override
  Widget build(BuildContext context) {
    final textEditToolsModel = context.watch<TextEditTools>();

    return ToggleButtons(
      isSelected: textEditToolsModel.toggleButtons,
      onPressed: (index) {
        textEditToolsModel.toggleButtons[index] =
            !textEditToolsModel.toggleButtons[index];
        if (textEditToolsModel.toggleButtons[index]) {
          switch (index) {
            case 0:
              textModel.style =
                  textModel.style.copyWith(fontWeight: FontWeight.bold);
              break;
            case 1:
              textModel.style =
                  textModel.style.copyWith(fontStyle: FontStyle.italic);
              break;
            case 2:
              textModel.style = textModel.style
                  .copyWith(decoration: TextDecoration.underline);
              break;
            default:
          }
        } else {
          switch (index) {
            case 0:
              textModel.style =
                  textModel.style.copyWith(fontWeight: FontWeight.normal);
              break;
            case 1:
              textModel.style =
                  textModel.style.copyWith(fontStyle: FontStyle.normal);
              break;
            case 2:
              textModel.style =
                  textModel.style.copyWith(decoration: TextDecoration.none);
              break;
            default:
          }
        }
        textEditToolsModel.toggleButtons = textEditToolsModel.toggleButtons;
      },
      children: const [
        Icon(Icons.format_bold_rounded),
        Icon(Icons.format_italic_rounded),
        Icon(Icons.format_underline_rounded),
      ],
    );
  }
}
