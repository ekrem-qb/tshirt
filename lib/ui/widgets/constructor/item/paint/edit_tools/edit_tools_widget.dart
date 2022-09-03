import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:provider/provider.dart';

import '../../../../library/color_picker.dart';
import '../../../../library/modal_sheet.dart';
import '../../item_model.dart';
import '../paint_model.dart';
import 'brush_size_indicator_model.dart';

class EditToolsWidget extends StatelessWidget {
  const EditToolsWidget({super.key, required this.paintModel});

  final PaintItem paintModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(CaseStyle.iconSize / 2),
      child: Column(
        children: [
          _ToolsWidget(paintModel),
          _BuildToolsWidget(paintModel),
        ],
      ),
    );
  }
}

class _ToolsWidget extends StatelessWidget {
  const _ToolsWidget(this.paintModel);

  final PaintItem paintModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToolItemWidget(
          paintModel: paintModel,
          type: PaintType.simpleLine,
          icon: Icons.edit,
          onTap: () =>
              paintModel.drawingController.setType = PaintType.simpleLine,
        ),
        _ToolItemWidget(
          paintModel: paintModel,
          type: PaintType.smoothLine,
          icon: Icons.brush,
          onTap: () =>
              paintModel.drawingController.setType = PaintType.smoothLine,
        ),
        _ToolItemWidget(
          paintModel: paintModel,
          type: PaintType.straightLine,
          icon: Icons.show_chart,
          onTap: () =>
              paintModel.drawingController.setType = PaintType.straightLine,
        ),
        _ToolItemWidget(
          paintModel: paintModel,
          type: PaintType.rectangle,
          icon: Icons.crop_din,
          onTap: () =>
              paintModel.drawingController.setType = PaintType.rectangle,
        ),
        _ToolItemWidget(
          paintModel: paintModel,
          type: PaintType.eraser,
          icon: Icons.auto_fix_normal,
          onTap: () => paintModel.drawingController.setType = PaintType.eraser,
        ),
      ],
    );
  }
}

class _ToolItemWidget extends StatelessWidget {
  const _ToolItemWidget({
    required this.paintModel,
    required this.type,
    required this.icon,
    required this.onTap,
  });

  final PaintType type;
  final IconData icon;
  final Function() onTap;
  final PaintItem paintModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: CaseStyle.iconSize * 1.5,
        height: CaseStyle.iconSize * 1.5,
        child: ExValueBuilder<DrawConfig>(
          valueListenable: paintModel.drawingController.drawConfig,
          shouldRebuild:
              (DrawConfig? previousDrawConfig, DrawConfig? newDrawConfig) =>
                  previousDrawConfig!.paintType == type ||
                  newDrawConfig!.paintType == type,
          builder: (_, DrawConfig? drawConfig, __) {
            return Icon(
              icon,
              color: drawConfig?.paintType == type
                  ? Theme.of(context).primaryColor
                  : null,
              size: CaseStyle.iconSize,
            );
          },
        ),
      ),
    );
  }
}

class _BuildToolsWidget extends StatelessWidget {
  const _BuildToolsWidget(this.paintModel);

  final PaintItem paintModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ChangeNotifierProvider(
            create: (_) => BrushSizeIndicator(),
            child: _BrushSizeIndicatorWidget(paintModel: paintModel)),
        SizedBox(
          width: CaseStyle.iconSize,
          height: CaseStyle.iconSize,
          child: ExValueBuilder<DrawConfig?>(
            valueListenable: paintModel.drawingController.drawConfig,
            shouldRebuild:
                (DrawConfig? previousDrawConfig, DrawConfig? newDrawConfig) =>
                    previousDrawConfig!.color != newDrawConfig!.color,
            builder: (_, DrawConfig? drawConfig, ___) {
              return TextButton(
                onPressed: () async {
                  showModal(
                    context: context,
                    dimBackground: true,
                    child: ColorPickerWidget(
                      color:
                          paintModel.drawingController.getColor ?? Colors.red,
                      onColorChanged: (newColor) =>
                          paintModel.drawingController.setColor = newColor,
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: drawConfig?.color,
                  shape: const RoundedRectangleBorder(),
                ),
                child: const SizedBox.shrink(),
              );
            },
          ),
        ),
        GestureDetector(
          onTap: () => paintModel.drawingController.undo(),
          child: const SizedBox(
            width: CaseStyle.iconSize * 1.6,
            child: Icon(
              Icons.undo_rounded,
              size: CaseStyle.iconSize,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => paintModel.drawingController.redo(),
          child: const SizedBox(
            width: CaseStyle.iconSize * 1.6,
            child: Icon(
              Icons.redo_rounded,
              size: CaseStyle.iconSize,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => paintModel.drawingController.clear(),
          child: const SizedBox(
            width: CaseStyle.iconSize * 1.6,
            child: Icon(Icons.clear_all, size: CaseStyle.iconSize),
          ),
        ),
      ],
    );
  }
}

class _BrushSizeIndicatorWidget extends StatelessWidget {
  const _BrushSizeIndicatorWidget({
    required this.paintModel,
  });

  final PaintItem paintModel;

  @override
  Widget build(BuildContext context) {
    BrushSizeIndicator? brushSizeIndicatorModel;
    final value = context.select((BrushSizeIndicator model) {
      brushSizeIndicatorModel ??= model;
      return model.value;
    });

    return Container(
      height: CaseStyle.iconSize * 1.6,
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SliderTheme(
        data: const SliderThemeData(
          thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: CaseStyle.iconSize / 2.5,
            elevation: 0,
          ),
          overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
        ),
        child: Slider(
          value: value,
          max: 50,
          min: 1,
          divisions: 50,
          label: value.floor().toString(),
          onChanged: (double newValue) =>
              brushSizeIndicatorModel!.value = newValue,
          onChangeEnd: (double newValue) =>
              paintModel.drawingController.setThickness = newValue,
        ),
      ),
    );
  }
}
