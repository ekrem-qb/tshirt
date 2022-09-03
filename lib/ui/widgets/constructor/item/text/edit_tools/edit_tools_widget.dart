import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../library/modal_sheet.dart';
import '../text_model.dart';
import 'edit_tools_model.dart';
import 'font_picker/font_picker_widget.dart';

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
      child: Column(
        children: [
          Row(
            children: [
              _FontFamilyPickWidget(textModel),
              _ColorPickWidget(textModel),
            ],
          ),
          _FontStyleWidget(textModel),
        ],
      ),
    );
  }
}

class _FontFamilyPickWidget extends StatelessWidget {
  const _FontFamilyPickWidget(this.textModel);

  final TextItem textModel;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: () {
        showModal(
          context: context,
          child: FontPickerWidget(
            textModel: textModel,
            currentFont: textModel.fontFamily,
          ),
        );
      },
      child: const Icon(Icons.title_rounded),
    );
  }
}

class _ColorPickWidget extends StatelessWidget {
  const _ColorPickWidget(this.textModel);

  final TextItem textModel;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: () {
        showModal(
          context: context,
          child: ConstrainedBox(
            constraints: const BoxConstraints.tightFor(
              height: 432,
            ),
            child: ColorPicker(
              hasBorder: true,
              wheelHasBorder: true,
              colorCodeHasColor: true,
              enableOpacity: true,
              subheading: const Text('Color shade'),
              wheelSubheading: const Text('Color shade'),
              opacitySubheading: const Text('Opacity'),
              pickersEnabled: const {
                ColorPickerType.primary: true,
                ColorPickerType.accent: false,
                ColorPickerType.wheel: true,
              },
              color: textModel.style.color ?? Colors.grey.shade900,
              onColorChanged: (newColor) =>
                  textModel.style = textModel.style.copyWith(color: newColor),
            ),
          ),
        );
      },
      child: const Icon(Icons.format_color_fill_rounded),
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
