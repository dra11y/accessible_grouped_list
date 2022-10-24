import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TruncatedSemanticsText extends StatefulWidget {
  const TruncatedSemanticsText(
    this.text, {
    super.key,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.softWrap,
    this.textAlign,
    this.locale,
    this.strutStyle,
    this.selectionColor,
    this.style,
    this.textDirection,
    this.textHeightBehavior,
    this.textScaleFactor,
    this.textWidthBasis,
  });

  final String text;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final TextAlign? textAlign;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final Color? selectionColor;
  final TextStyle? style;
  final TextDirection? textDirection;
  final TextHeightBehavior? textHeightBehavior;
  final double? textScaleFactor;
  final TextWidthBasis? textWidthBasis;

  @override
  State<TruncatedSemanticsText> createState() => _TruncatedSemanticsTextState();
}

class _TruncatedSemanticsTextState extends State<TruncatedSemanticsText>
    with WidgetsBindingObserver {
  String text = '';
  String? semanticsLabel;
  final _visibilityKey = GlobalKey();
  final _textKey = GlobalKey();
  Size? windowSize;

  @override
  void initState() {
    super.initState();
    text = widget.text;
    windowSize = WidgetsBinding.instance.window.physicalSize;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void clearSemanticsLabel() {
    setState(() {
      semanticsLabel = null;
    });
  }

  @override
  void didChangeMetrics() {
    if (windowSize == WidgetsBinding.instance.window.physicalSize) return;
    windowSize = WidgetsBinding.instance.window.physicalSize;
    clearSemanticsLabel();
  }

  @override
  void didChangeLocales(List<Locale>? locales) => clearSemanticsLabel();

  @override
  void didChangeAccessibilityFeatures() => clearSemanticsLabel();

  @override
  void didChangeTextScaleFactor() => clearSemanticsLabel();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      clearSemanticsLabel();

  int findLength({
    required RenderParagraph paragraph,
    required int start,
    required int end,
    int current = 0,
  }) {
    final mid = (start + end) ~/ 2;
    final selection = TextSelection(baseOffset: mid, extentOffset: mid + 1);
    final isTruncated = paragraph.getBoxesForSelection(selection).isEmpty;
    final int result;
    if (isTruncated) {
      if (start == mid) return current;
      result = findLength(
        paragraph: paragraph,
        start: start,
        end: mid,
        current: current,
      );
    } else {
      if (start == mid) return mid + 1;
      result = findLength(
        paragraph: paragraph,
        start: mid + 1,
        end: end,
        current: mid + 1,
      );
    }
    return max(current, result);
  }

  @override
  Widget build(BuildContext context) {
    if (semanticsLabel == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        final paragraph =
            _textKey.currentContext?.findRenderObject() as RenderParagraph?;
        if (paragraph == null) {
          semanticsLabel = text; // Set it to text so we don't loop.
          return;
        }

        final length =
            findLength(paragraph: paragraph, start: 0, end: text.length);

        final suffix = length < text.length ? ' …' : '';

        setState(() {
          semanticsLabel = text.substring(0, length) + suffix;
        });
      });
    }

    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: Text(
        text,
        key: _textKey,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        softWrap: widget.softWrap,
        textAlign: widget.textAlign,
        locale: widget.locale,
        strutStyle: widget.strutStyle,
        selectionColor: widget.selectionColor,
        style: widget.style,
        textDirection: widget.textDirection,
        textHeightBehavior: widget.textHeightBehavior,
        textScaleFactor: widget.textScaleFactor,
        textWidthBasis: widget.textWidthBasis,
      ),
    );
  }
}
