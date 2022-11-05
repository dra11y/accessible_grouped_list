import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccessibleGroupedList extends StatelessWidget {
  const AccessibleGroupedList({
    super.key,
    required this.cacheExtent,
    required this.slivers,
    required ScrollController scrollController,
    required GlobalKey scrollKey,
  })  : _scrollController = scrollController,
        _scrollKey = scrollKey;

  // The maximum distance between two headings in the list, in pixels.
  final double cacheExtent;
  final List<Widget> slivers;
  final ScrollController _scrollController;
  final GlobalKey _scrollKey;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      cacheExtent: cacheExtent,
      key: _scrollKey,
      controller: _scrollController,
      slivers: slivers,
    );
  }
}
