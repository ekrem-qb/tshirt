import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../../../../resources/filters.dart';
import '../../image_model.dart';

@immutable
class FilterPickerWidget extends StatefulWidget {
  const FilterPickerWidget(this.imageModel, {super.key});

  final ImageItem imageModel;

  final EdgeInsets padding = const EdgeInsets.symmetric(vertical: 64);

  @override
  _FilterPickerWidgetState createState() => _FilterPickerWidgetState();
}

class _FilterPickerWidgetState extends State<FilterPickerWidget> {
  /// filter per screen is by default five
  static const _filtersPerScreen = 5;

  /// screen responsiveness with filters
  static const _viewportFractionPerItem = 1.0 / _filtersPerScreen;

  ///initializer of page controller
  late final PageController _controller;

  ///page number
  late int _page;

  /// filter count form filter list
  int get filterCount => filterPresets.length;

  List<double> itemColor(int index) =>
      filterPresets.values.elementAt(index % filterCount);

  @override
  void initState() {
    super.initState();
    _page = filterPresets.values.toList().indexOf(widget.imageModel.filter);
    _controller = PageController(
      initialPage: _page,
      viewportFraction: _viewportFractionPerItem,
    );
    _controller.addListener(_onPageChanged);
  }

  /// call when filter changes
  void _onPageChanged() {
    final page = (_controller.page ?? 0).round();
    if (page != _page) {
      _page = page;
      widget.imageModel.filter = filterPresets.values.elementAt(page);
    }
  }

  ///call when tap on filters
  void _onFilterTapped(int index) {
    widget.imageModel.filter = filterPresets.values.elementAt(index);
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutExpo,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollable(
      controller: _controller,
      axisDirection: AxisDirection.right,
      physics: const PageScrollPhysics(),
      viewportBuilder: (context, viewportOffset) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final itemSize = constraints.maxWidth * _viewportFractionPerItem;
            viewportOffset
              ..applyViewportDimension(constraints.maxWidth)
              ..applyContentDimensions(0.0, itemSize * (filterCount - 1));

            return Stack(
              alignment: Alignment.center,
              children: [
                _buildCarousel(
                  viewportOffset: viewportOffset,
                  itemSize: itemSize,
                ),
                _buildSelectionRing(itemSize),
              ],
            );
          },
        );
      },
    );
  }

  ///carousel slider of filters
  Widget _buildCarousel({
    required ViewportOffset viewportOffset,
    required double itemSize,
  }) {
    return Container(
      height: itemSize,
      margin: widget.padding,
      child: Flow(
        delegate: CarouselFlowDelegate(
          viewportOffset: viewportOffset,
          filtersPerScreen: _filtersPerScreen,
        ),
        children: [
          for (int i = 0; i < filterCount; i++)
            FilterItem(
              imageModel: widget.imageModel,
              onFilterSelected: () => _onFilterTapped(i),
              filter: itemColor(i),
            ),
        ],
      ),
    );
  }

  /// filters ui
  Widget _buildSelectionRing(double itemSize) {
    return IgnorePointer(
      child: Padding(
        padding: widget.padding,
        child: SizedBox(
          width: itemSize,
          height: itemSize,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(
                  width: 6.0,
                  color: IconTheme.of(context).color ?? Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CarouselFlowDelegate extends FlowDelegate {
  CarouselFlowDelegate({
    required this.viewportOffset,
    required this.filtersPerScreen,
  }) : super(repaint: viewportOffset);

  final ViewportOffset viewportOffset;
  final int filtersPerScreen;

  @override
  void paintChildren(FlowPaintingContext context) {
    final count = context.childCount;

    /// All available painting width
    final size = context.size.width;

    /// The distance that a single item "page" takes up from the perspective
    /// of the scroll paging system. We also use this size for the width and
    /// height of a single item.
    final itemExtent = size / filtersPerScreen;

    /// The current scroll position expressed as an item fraction, e.g., 0.0,
    /// or 1.0, or 1.3, or 2.9, etc. A value of 1.3 indicates that item at
    /// index 1 is active, and the user has scrolled 30% towards the item at
    /// index 2.
    final active = viewportOffset.pixels / itemExtent;

    /// Index of the first item we need to paint at this moment.
    /// At most, we paint 3 items to the left of the active item.
    final int min = math.max(0, active.floor() - 3);

    /// Index of the last item we need to paint at this moment.
    /// At most, we paint 3 items to the right of the active item.
    final int max = math.min(count - 1, active.ceil() + 3);

    /// Generate transforms for the visible items and sort by distance.
    for (var index = min; index <= max; index++) {
      final itemXFromCenter = itemExtent * index - viewportOffset.pixels;
      final percentFromCenter = 1.0 - (itemXFromCenter / (size / 2)).abs();
      final itemScale = 0.5 + (percentFromCenter * 0.5);
      final opacity = 0.25 + (percentFromCenter * 0.75);

      final itemTransform = Matrix4.identity()
        ..translate((size - itemExtent) / 2)
        ..translate(itemXFromCenter)
        ..translate(itemExtent / 2, itemExtent / 2)
        ..multiply(Matrix4.diagonal3Values(itemScale, itemScale, 1.0))
        ..translate(-itemExtent / 2, -itemExtent / 2);

      context.paintChild(
        index,
        transform: itemTransform,
        opacity: opacity,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CarouselFlowDelegate oldDelegate) {
    return oldDelegate.viewportOffset != viewportOffset;
  }
}

@immutable
class FilterItem extends StatelessWidget {
  const FilterItem({
    super.key,
    required this.imageModel,
    required this.filter,
    this.onFilterSelected,
  });

  final List<double> filter;
  final VoidCallback? onFilterSelected;
  final ImageItem imageModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFilterSelected,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: ClipOval(
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: CircleBorder(
                side: BorderSide(
                    color: IconTheme.of(context).color ?? Colors.black),
              ),
            ),
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(filter),
              child: Image(
                image: imageModel.image,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
