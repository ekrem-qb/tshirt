import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../../theme.dart';
import '../../text_model.dart';
import 'font_picker_model.dart';

class FontPickerWidget extends StatelessWidget {
  const FontPickerWidget({
    super.key,
    required this.textModel,
    required this.currentFont,
  });

  final TextItem textModel;
  final String currentFont;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FontPicker(textModel, currentFont),
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 4,
        child: _FontsGridWidget(textModel),
      ),
    );
  }
}

class _FontsGridWidget extends StatelessWidget {
  const _FontsGridWidget(this.textModel);

  final TextItem textModel;

  @override
  Widget build(BuildContext context) {
    FontPicker? fontPickerModel;
    final fonts = context.select((FontPicker model) {
      fontPickerModel ??= model;
      return model.fonts;
    });

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
      ),
      itemCount: fonts.length,
      itemBuilder: (context, index) {
        return _FontWidget(
          textModel: textModel,
          fonts: fonts,
          index: index,
        );
      },
    );
  }
}

class _FontWidget extends StatelessWidget {
  const _FontWidget({
    required this.textModel,
    required this.fonts,
    required this.index,
  });

  final TextItem textModel;
  final List<String> fonts;
  final int index;

  @override
  Widget build(BuildContext context) {
    FontPicker? fontPickerModel;
    final selectedIndex = context.select((FontPicker model) {
      fontPickerModel ??= model;
      return model.selectedIndex;
    });

    return Card(
      elevation: 8,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        onTap: () {
          textModel.style = textModel.style.copyWith(
            fontFamily: GoogleFonts.getFont(
              fonts[index],
            ).fontFamily,
          );
          textModel.fontFamily = fonts[index];
          fontPickerModel?.selectedIndex = index;
        },
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(buttonsSpacing),
            child: Text(
              fonts[index],
              style: GoogleFonts.getFont(
                fonts[index],
                color: index == selectedIndex ? Colors.blue : null,
              ),
              // maxLines: 1,
              // overflow: TextOverflow.fade,
              // softWrap: false,
            ),
          ),
        ),
      ),
    );
  }
}
