import 'package:flutter/material.dart';

import './extension_like_kotlin.dart';

abstract class _BaseFlex extends StatelessWidget {
  final FlexDirection direction;
  final bool isShowingProgress;
  final Widget Function(FlexLayoutConstraints constraints)? builder;
  final bool neededOffset;

  const _BaseFlex({
    super.key,
    required this.builder,
    required this.direction,
    required this.isShowingProgress,
    required this.neededOffset,
  });

  Widget buildLayout(
    double width,
    double height, {
    bool shouldSizedBox = true,
    AlignmentGeometry? alignment,
    Decoration? decoration,
    Decoration? foregroundDecoration,
    EdgeInsets? padding,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    Clip? clipBehavior,
    GlobalKey? outerKey,
    EdgeInsets? innerPadding,
    EdgeInsets? outerPadding,
  }) {
    return buildLayoutByBuilder(
      width,
      height,
      builder,
      shouldSizedBox: shouldSizedBox,
      alignment: alignment,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      padding: padding,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      outerKey: outerKey ?? GlobalKey(),
      shouldSetOuterKey: outerKey == null,
      innerPadding: innerPadding,
      outerPadding: outerPadding,
    );
  }

  Widget buildLayoutByBuilder(
    double width,
    double height,
    Widget Function(FlexLayoutConstraints)? builder, {
    bool shouldSizedBox = true,
    AlignmentGeometry? alignment,
    Decoration? decoration,
    Decoration? foregroundDecoration,
    EdgeInsets? padding,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    Clip? clipBehavior,
    GlobalKey? outerKey,
    bool shouldSetOuterKey = false,
    EdgeInsets? innerPadding,
    EdgeInsets? outerPadding,
  }) {
    assert(width >= 0);
    assert(height >= 0);

    Widget body;

    if (shouldSizedBox ||
        (alignment == null &&
            decoration == null &&
            foregroundDecoration == null &&
            padding == null &&
            transform == null &&
            transformAlignment == null &&
            clipBehavior == null)) {
      body = SizedBox(
        width: width,
        height: height,
        child: (builder ?? (_) => const SizedBox())(
          FlexLayoutConstraints(
            outerKey: outerKey,
            parentWidth: width,
            parentHeight: height,
            direction: direction,
            border: (decoration as BoxDecoration?)?.border,
            innerPadding: innerPadding,
            padding: outerPadding,
          ),
        ),
      );
    } else {
      var finalWidth = width;
      var finalHeight = height;

      padding?.also((padding) {
        finalWidth -= padding.left + padding.right;
        finalHeight -= padding.top + padding.bottom;
      });

      (decoration as BoxDecoration?)?.also((decoration) {
        decoration.border?.also((border) {
          finalHeight -= border.top.width + border.bottom.width;
          (border as Border?)?.also((border) {
            finalWidth -= border.left.width + border.right.width;
          });
        });
      });

      body = Container(
        width: width,
        height: height,
        alignment: alignment,
        decoration: decoration,
        foregroundDecoration: foregroundDecoration,
        padding: padding,
        transform: transform,
        transformAlignment: transformAlignment,
        clipBehavior: clipBehavior ?? Clip.none,
        child: (builder ?? (_) => const SizedBox())(
          FlexLayoutConstraints(
            outerKey: outerKey,
            parentWidth: finalWidth,
            parentHeight: finalHeight,
            direction: direction,
            border: decoration.to<BoxDecoration>()?.border,
            innerPadding: innerPadding,
            padding: outerPadding,
          ),
        ),
      );
    }

    return Stack(
      key: neededOffset && shouldSetOuterKey ? outerKey : null,
      children: [
        body,
        if (isShowingProgress)
          SizedBox(
            width: width,
            height: height,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                width: width,
                height: width,
                padding: const EdgeInsets.all(10),
                child: const CircularProgressIndicator(
                  strokeWidth: 20,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class FlexLayout extends _BaseFlex {
  final double? width;
  final double? maxWidth;
  final double? minWidth;

  final double? height;
  final double? maxHeight;
  final double? minHeight;

  final EdgeInsets? padding;

  final bool isSafeArea;
  final bool? isTopSafeArea;
  final bool? isBottomSafeArea;
  final bool? isLeftSafeArea;
  final bool? isRightSafeArea;

  FlexLayout({
    super.key,
    super.isShowingProgress = false,
    required Widget Function(FlexLayoutSize size) builder,
    this.height,
    this.width,
    this.maxHeight,
    this.minHeight,
    this.maxWidth,
    this.minWidth,
    this.padding,
    this.isSafeArea = false,
    this.isTopSafeArea,
    this.isBottomSafeArea,
    this.isLeftSafeArea,
    this.isRightSafeArea,
    bool neededOffset = false,
  }) : assert((maxHeight ?? double.maxFinite) > (minHeight ?? 0)),
       assert((maxWidth ?? double.maxFinite) > (minWidth ?? 0)),
       assert((maxHeight ?? 1) > 0),
       assert((minHeight ?? 1) > 0),
       assert((maxWidth ?? 1) > 0),
       assert((minWidth ?? 1) > 0),
       assert((height ?? 1) > 0),
       assert((width ?? 1) > 0),
       super(
         builder: (constraints) => builder(constraints.extend()),
         neededOffset: neededOffset,
         direction: FlexDirection.column,
       );

  @override
  Widget build(BuildContext context) {
    if (width != null && height != null) {
      return padding == null
          ? buildLayout(width!, height!)
          : (neededOffset ? GlobalKey() : null).let(
            (key) => Container(
              key: key,
              width: width!,
              height: height!,
              padding: padding,
              child: buildLayout(
                width! - padding!.right - padding!.left,
                height! - padding!.top - padding!.bottom,
                outerKey: key,
                outerPadding: padding,
              ),
            ),
          );
    } else {
      final body = LayoutBuilder(
        builder: (context, baseConstraints) {
          final finalWidth =
              width ??
              ((maxWidth != null && baseConstraints.maxWidth > maxWidth!)
                  ? maxWidth!
                  : (minWidth != null && baseConstraints.maxWidth < minWidth!)
                  ? minWidth!
                  : baseConstraints.maxWidth);

          final finalHeight =
              height ??
              ((maxHeight != null && baseConstraints.maxHeight > maxHeight!)
                  ? maxHeight!
                  : (minHeight != null &&
                      baseConstraints.maxHeight < minHeight!)
                  ? minHeight!
                  : baseConstraints.maxHeight);

          return padding == null
              ? buildLayout(finalWidth, finalHeight)
              : (neededOffset ? GlobalKey() : null).let(
                (key) => Container(
                  key: key,
                  width: finalWidth,
                  height: finalHeight,
                  padding: padding,
                  child: buildLayout(
                    finalWidth - padding!.left - padding!.right,
                    finalHeight - padding!.top - padding!.bottom,
                    outerKey: key,
                    outerPadding: padding,
                  ),
                ),
              );
        },
      );

      if (isSafeArea) {
        return SafeArea(child: body);
      } else if ((isTopSafeArea ??
              isBottomSafeArea ??
              isLeftSafeArea ??
              isRightSafeArea) ==
          null) {
        return body;
      } else {
        return SafeArea(
          bottom: isBottomSafeArea ?? false,
          top: isTopSafeArea ?? false,
          left: isLeftSafeArea ?? false,
          right: isRightSafeArea ?? false,
          child: body,
        );
      }
    }
  }
}

// class FlexContainer

class FlexColum extends StatelessWidget {
  final FlexLayoutSize size;

  final List<Widget> Function(FlexLayoutConstraints constraints) builder;

  final EdgeInsets? padding;

  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final EdgeInsets? innerPadding;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Clip? clipBehavior;
  final bool isShowingProgress;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  final bool neededOffset;

  const FlexColum({
    super.key,
    required this.size,
    this.isShowingProgress = false,
    this.padding,
    required this.builder,
    this.decoration,
    this.foregroundDecoration,
    this.innerPadding,
    this.transform,
    this.transformAlignment,
    this.clipBehavior,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.neededOffset = false,
  });

  @override
  Widget build(BuildContext context) => FlexContainer(
    key: key,
    size: size,
    direction: FlexDirection.column,
    builder:
        (constraints) => Column(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: builder(constraints),
        ),
    isShowingProgress: isShowingProgress,
    padding: padding,
    decoration: decoration,
    foregroundDecoration: foregroundDecoration,
    innerPadding: innerPadding,
    transform: transform,
    transformAlignment: transformAlignment,
    clipBehavior: clipBehavior,
    neededOffset: neededOffset,
  );
}

class FlexRow extends StatelessWidget {
  final FlexLayoutSize size;

  final List<Widget> Function(FlexLayoutConstraints constraints) builder;

  final EdgeInsets? padding;

  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final EdgeInsets? innerPadding;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Clip? clipBehavior;
  final bool isShowingProgress;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  final bool neededOffset;

  const FlexRow({
    super.key,
    required this.size,
    this.isShowingProgress = false,
    this.padding,
    required this.builder,
    this.decoration,
    this.foregroundDecoration,
    this.innerPadding,
    this.transform,
    this.transformAlignment,
    this.clipBehavior,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.neededOffset = false,
  });

  @override
  Widget build(BuildContext context) => FlexContainer(
    key: key,
    size: size,
    direction: FlexDirection.row,
    builder:
        (constraints) => Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: builder(constraints),
        ),
    isShowingProgress: isShowingProgress,
    padding: padding,
    decoration: decoration,
    foregroundDecoration: foregroundDecoration,
    innerPadding: innerPadding,
    transform: transform,
    transformAlignment: transformAlignment,
    clipBehavior: clipBehavior,
    neededOffset: neededOffset,
  );
}

class FlexStack extends StatelessWidget {
  final FlexLayoutSize size;

  final List<Widget> Function(FlexLayoutSize size) builder;

  final EdgeInsets? padding;

  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final EdgeInsets? innerPadding;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Clip? clipBehavior;
  final bool isShowingProgress;
  final AlignmentGeometry alignment;
  final StackFit fit;
  final Clip stackClipBehavior;

  final bool neededOffset;

  const FlexStack({
    super.key,
    required this.size,
    this.isShowingProgress = false,
    this.padding,
    required this.builder,
    this.decoration,
    this.foregroundDecoration,
    this.innerPadding,
    this.transform,
    this.transformAlignment,
    this.clipBehavior,
    this.alignment = AlignmentDirectional.topStart,
    this.fit = StackFit.loose,
    this.stackClipBehavior = Clip.hardEdge,
    this.neededOffset = false,
  });

  @override
  Widget build(BuildContext context) => FlexContainer(
    key: key,
    size: size,
    direction: FlexDirection.column,
    builder:
        (constraints) => Stack(
          alignment: alignment,
          fit: fit,
          clipBehavior: stackClipBehavior,
          children: builder(constraints.copyWith().extend()),
        ),
    isShowingProgress: isShowingProgress,
    padding: padding,
    decoration: decoration,
    foregroundDecoration: foregroundDecoration,
    innerPadding: innerPadding,
    transform: transform,
    transformAlignment: transformAlignment,
    clipBehavior: clipBehavior,
    neededOffset: neededOffset,
  );
}

class FlexContainer extends _BaseFlex {
  final FlexLayoutSize size;

  final EdgeInsets? padding;

  final AlignmentGeometry? alignment;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final EdgeInsets? innerPadding;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Clip? clipBehavior;

  const FlexContainer({
    super.key,
    super.direction = FlexDirection.column,
    required this.size,
    super.isShowingProgress = false,
    this.padding,
    Widget Function(FlexLayoutConstraints constraints)? builder,
    this.alignment,
    this.decoration,
    this.foregroundDecoration,
    this.innerPadding,
    this.transform,
    this.transformAlignment,
    this.clipBehavior,
    bool neededOffset = false,
  }) : super(builder: builder, neededOffset: neededOffset);

  @override
  Widget build(BuildContext context) {
    return padding == null
        ? buildLayout(
          size.width,
          size.height,
          shouldSizedBox: false,
          alignment: alignment,
          decoration: decoration,
          foregroundDecoration: foregroundDecoration,
          padding: innerPadding,
          transform: transform,
          transformAlignment: transformAlignment,
          clipBehavior: clipBehavior,
          innerPadding: innerPadding,
        )
        : (neededOffset ? GlobalKey() : null).let(
          (key) => Container(
            key: key,
            width: size.width,
            height: size.height,
            padding: padding,
            child: buildLayout(
              size.width - padding!.left - padding!.right,
              size.height - padding!.top - padding!.bottom,
              innerPadding: innerPadding,
              outerPadding: padding,
              outerKey: key,
              shouldSizedBox: false,
              alignment: alignment,
              decoration: decoration,
              foregroundDecoration: foregroundDecoration,
              padding: innerPadding,
              transform: transform,
              transformAlignment: transformAlignment,
              clipBehavior: clipBehavior,
            ),
          ),
        );
  }
}

class FlexSimpleItem extends _BaseFlex {
  final FlexLayoutSize size;

  final EdgeInsets? padding;

  const FlexSimpleItem({
    super.key,
    super.direction = FlexDirection.column,
    required this.size,
    super.isShowingProgress = false,
    this.padding,
    super.neededOffset = false,
    Widget Function(FlexLayoutConstraints constraints)? builder,
  }) : super(builder: builder);

  @override
  Widget build(BuildContext context) {
    return padding == null
        ? buildLayout(size.width, size.height)
        : (neededOffset ? GlobalKey() : null).let(
          (key) => Container(
            key: key,
            width: size.width,
            height: size.height,
            padding: padding,
            child: buildLayout(
              size.width - padding!.left - padding!.right,
              size.height - padding!.top + padding!.bottom,
              outerPadding: padding,
              outerKey: key,
            ),
          ),
        );
  }
}

class FlexSpacer extends _BaseFlex {
  final FlexLayoutSize size;

  const FlexSpacer({super.key, required this.size})
    : super(
        builder: null,
        direction: FlexDirection.column,
        isShowingProgress: false,
        neededOffset: false,
      );

  @override
  Widget build(BuildContext context) {
    return buildLayout(size.width, size.height);
  }
}

class FlexDialog extends _BaseFlex {
  final Widget Function(FlexLayoutConstraints constraints)? title;

  final double? width;
  final double? maxWidth;
  final double? minWidth;

  final double? height;
  final double? maxHeight;
  final double? minHeight;

  final double titleHeight;

  final EdgeInsets? insetPadding;

  static const recommendedPadding = EdgeInsets.symmetric(
    vertical: 30,
    horizontal: 40,
  );

  late final bool _isShowingProgress;

  final void Function(FlexLayoutSize size)? flexDialogLayoutConstraintsCallback;

  late final bool _neededOffset;

  final EdgeInsets? padding;

  final Color? backgroundColor;

  final Color? shadowColor;

  final bool isSafeArea;

  FlexDialog({
    super.key,
    super.direction = FlexDirection.column,
    bool isShowingProgress = false,
    required super.builder,
    this.title,
    this.width,
    this.maxWidth,
    this.minWidth,
    this.height,
    this.maxHeight,
    this.titleHeight = 30,
    this.minHeight,
    this.insetPadding,
    this.padding,
    this.backgroundColor,
    this.flexDialogLayoutConstraintsCallback,
    bool neededOffset = false,
    this.shadowColor,
    this.isSafeArea = true,
  }) : assert((maxHeight ?? double.maxFinite) > (minHeight ?? 0)),
       assert((maxWidth ?? double.maxFinite) > (minWidth ?? 0)),
       assert((maxHeight ?? 1) > 0),
       assert((minHeight ?? 1) > 0),
       assert((maxWidth ?? 1) > 0),
       assert((minWidth ?? 1) > 0),
       assert((height ?? 1) > 0),
       assert((width ?? 1) > 0),
       super(isShowingProgress: false, neededOffset: false) {
    _neededOffset = neededOffset;
    _isShowingProgress = isShowingProgress;
  }

  @override
  Widget build(BuildContext context) {
    var finalInsetPadding =
        insetPadding ??
        const EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 0);

    return FlexLayout(
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      width: width,
      height: height,
      minHeight: minHeight,
      minWidth: minWidth,
      isShowingProgress: _isShowingProgress,
      neededOffset: _neededOffset,
      padding: padding,
      isSafeArea: isSafeArea,
      builder:
          (size) => SizedBox(
            width: size.width,
            height: size.height,
            child: SimpleDialog(
              title:
                  title == null
                      ? null
                      : buildLayoutByBuilder(
                        size.width -
                            finalInsetPadding.right -
                            finalInsetPadding.left,
                        titleHeight,
                        title,
                        outerPadding: EdgeInsets.only(
                          right: finalInsetPadding.right,
                          left: finalInsetPadding.left,
                          top: finalInsetPadding.top,
                        ),
                      ),
              shadowColor: shadowColor,
              backgroundColor: backgroundColor,
              insetPadding: finalInsetPadding,
              contentPadding: const EdgeInsets.all(0),
              children: [
                buildLayout(
                  size.width - finalInsetPadding.right - finalInsetPadding.left,
                  size.height -
                      (title == null ? 0 : titleHeight) -
                      finalInsetPadding.top -
                      finalInsetPadding.bottom,
                  outerPadding: EdgeInsets.only(
                    right: finalInsetPadding.right,
                    left: finalInsetPadding.left,
                    top: title == null ? finalInsetPadding.top : 0,
                    bottom: finalInsetPadding.bottom,
                  ),
                ).also((it) {
                  flexDialogLayoutConstraintsCallback?.also((it) => it(size));
                }),
              ],
            ),
          ),
    );
  }
}

class FlexLayoutConstraints {
  /// parent's body width
  final double parentWidth;

  /// parent's body height
  final double parentHeight;

  /// direction
  final FlexDirection direction;

  late final GlobalKey? _outerKey;
  final BoxBorder? border;
  final EdgeInsets? padding;
  final EdgeInsets? innerPadding;

  double _weightSum = 0;
  double _sideLengthSum = 0;

  FlexLayoutConstraints({
    required this.parentWidth,
    required this.parentHeight,
    required this.direction,
    GlobalKey? outerKey,
    this.border,
    this.innerPadding,
    this.padding,
  }) {
    _outerKey = outerKey;
  }

  FlexLayoutConstraints copyWith() => FlexLayoutConstraints(
    parentHeight: parentHeight,
    parentWidth: parentWidth,
    direction: direction,
    border: border,
    innerPadding: innerPadding,
    outerKey: _outerKey,
    padding: padding,
  ).._sideLengthSum = _sideLengthSum;

  /// parent's body size
  Size get parentSize => Size(parentWidth, parentHeight);

  /// parent's body offset
  Offset? get parentOffset => inBorderOffset?.let(
    (parent) =>
        innerPadding?.let(
          (padding) =>
              Offset(parent.dx + padding.left, parent.dy + padding.top),
        ) ??
        parent,
  );

  /// size include innerPadding (without border)
  Size get inBorderSize {
    var inPadding = innerPadding;

    if (inPadding == null) {
      return parentSize;
    } else {
      return Size(
        parentWidth + inPadding.horizontal,
        parentHeight + inPadding.vertical,
      );
    }
  }

  /// offset include innerPadding
  Offset? get inBorderOffset => borderOffset?.let(
    (parent) =>
        border?.let(
          (border) => Offset(
            parent.dx +
                ((border as Border?)?.let(
                      (border) => border.left.width + border.right.width,
                    ) ??
                    0),
            parent.dy + border.top.width + border.bottom.width,
          ),
        ) ??
        parent,
  );

  /// size include innerPadding + border
  Size get borderSize {
    var mBorder = border;
    var base = inBorderSize;

    if (mBorder == null) {
      return inBorderSize;
    } else {
      return Size(
        base.width +
            ((mBorder as Border?)?.let(
                  (border) => border.left.width + border.right.width,
                ) ??
                0),
        base.height + mBorder.top.width + mBorder.bottom.width,
      );
    }
  }

  /// offset include innerPadding + border
  Offset? get borderOffset => outerOffset?.let(
    (parent) =>
        padding?.let(
          (padding) =>
              Offset(parent.dx + padding.left, parent.dy + padding.top),
        ) ??
        parent,
  );

  /// size include innerPadding + border + padding
  Size get outerSize {
    var mPadding = padding;
    var borderSize = this.borderSize;

    if (mPadding == null) {
      return borderSize;
    } else {
      return Size(
        borderSize.width + mPadding.horizontal,
        borderSize.height + mPadding.vertical,
      );
    }
  }

  /// offset include innerPadding + border + padding
  Offset? get outerOffset =>
      (_outerKey?.currentContext?.findRenderObject() as RenderBox?)
          ?.localToGlobal(Offset.zero);

  double get weightLength {
    return ((direction == FlexDirection.column ? parentHeight : parentWidth) -
            _sideLengthSum) /
        (_weightSum > 0 ? _weightSum : 1);
  }

  FlexLayoutSize weight(double weight) {
    assert(weight > 0);
    _weightSum += weight;
    return FlexLayoutSize(this, weight: weight);
  }

  FlexLayoutSize extend() {
    return weight(1);
  }

  FlexLayoutSize sideLength(double sideLength) {
    assert(sideLength >= 0);
    _sideLengthSum += sideLength;
    return FlexLayoutSize(this, sideLength: sideLength);
  }
}

class FlexLayoutSize {
  final FlexLayoutConstraints _constraints;
  double? weight;
  double? sideLength;

  double? _width;
  double? _height;
  double? _cross;

  FlexLayoutSize(this._constraints, {this.sideLength, this.weight})
    : assert(weight != null || sideLength != null);

  static FlexLayoutSize size({
    required double width,
    required double height,
    FlexDirection direction = FlexDirection.column,
  }) {
    return FlexLayoutConstraints(
      parentWidth: width,
      parentHeight: height,
      direction: direction,
    ).extend();
  }

  double get width {
    return _width ??
        (_constraints.direction == FlexDirection.column
            ? _cross ?? _constraints.parentWidth
            : weight != null
            ? _constraints.weightLength * weight!
            : sideLength!);
  }

  double get height {
    return _height ??
        (_constraints.direction == FlexDirection.row
            ? _cross ?? _constraints.parentHeight
            : weight != null
            ? _constraints.weightLength * weight!
            : sideLength!);
  }

  FlexLayoutSize copyWith() {
    final rtn = FlexLayoutSize(
      _constraints,
      sideLength: sideLength,
      weight: weight,
    );

    rtn._width = _width;
    rtn._height = _height;
    rtn._cross = _cross;

    return rtn;
  }

  FlexLayoutSize setWidth(double val) {
    final rtn = copyWith();
    rtn._width = val;
    return rtn;
  }

  FlexLayoutSize setHeight(double val) {
    final rtn = copyWith();
    rtn._height = val;
    return rtn;
  }

  FlexLayoutSize cross(double val) {
    final rtn = copyWith();
    rtn._cross = val;
    return rtn;
  }
}

enum FlexDirection { column, row }
