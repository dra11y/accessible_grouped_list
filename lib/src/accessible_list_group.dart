import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'dynamic_icon.dart';
import 'platform_list_tile.dart';
import 'truncated_semantics_text.dart';

const double accessibilityScrollMargin = 100.0;

class AccessibleListGroup<Group, Item> extends StatelessWidget {
  final int groupIndex; // Fix accessibility scrolling, except on first item.
  final Group group;
  final List<Item> items;
  final bool autoTruncateSemanticsLabel;
  final Function(Item)? onTapItem;
  final Widget Function(Group)? groupWidget;
  final String Function(Group)? groupTitle;
  final Widget Function(Item)? itemWidget;
  final String Function(Item)? itemTitle;
  final int itemMaxLines;
  final TextStyle? groupTextStyle;
  final TextStyle? itemTextStyle;
  final ScrollController _scrollController;
  final GlobalKey _scrollKey;
  final _headerKey = GlobalKey();
  final Widget? divider;

  AccessibleListGroup({
    super.key,
    required this.groupIndex,
    required this.group,
    required this.items,
    this.autoTruncateSemanticsLabel = true,
    this.groupTextStyle,
    this.itemTextStyle,
    this.groupTitle,
    this.groupWidget,
    this.itemTitle,
    this.itemWidget,
    this.itemMaxLines = 1,
    this.divider,
    this.onTapItem,
    required ScrollController scrollController,
    required GlobalKey scrollKey,
  })  : _scrollController = scrollController,
        _scrollKey = scrollKey,
        assert(groupTitle != null || groupWidget != null),
        assert(itemTitle != null || itemWidget != null);

  @override
  Widget build(BuildContext context) => MultiSliver(
        pushPinnedChildren: true,
        children: [
          SliverStack(
            insetOnOverlap: true,
            children: [
              MultiSliver(
                children: <Widget>[
                  buildHeader(context),
                  buildItems(),
                ],
              ),
            ],
          ),
        ],
      );

  SliverPinnedHeader buildHeader(BuildContext context) => SliverPinnedHeader(
        child: Semantics(
          onDidGainAccessibilityFocus: () {
            if (groupIndex == 0) {
              _scrollController.jumpTo(0);
              return;
            }

            final scrollBox =
                _scrollKey.currentContext?.findRenderObject() as RenderBox?;
            if (scrollBox == null) return;
            final scrollBoxTop = scrollBox.localToGlobal(Offset.zero).dy;
            final scrollBoxBottom = scrollBoxTop + scrollBox.size.height;

            final headerBox =
                _headerKey.currentContext?.findRenderObject() as RenderBox?;
            if (headerBox == null) return;
            final headerTop = headerBox.localToGlobal(Offset.zero).dy;
            final headerBottom = headerTop + headerBox.size.height;

            final safeTop = scrollBoxTop +
                (groupIndex == 0
                    ? 0
                    : headerBox.size.height + accessibilityScrollMargin);

            final safeBottom = scrollBoxBottom - headerBox.size.height - 2;
            double diff;
            if (headerTop < safeTop) {
              diff = safeTop - headerTop;
            } else if (headerBottom > safeBottom) {
              diff = safeBottom - headerBottom;
            } else {
              return;
            }

            _scrollController.jumpTo(_scrollController.offset - diff);
          },
          child: Semantics(
            key: _headerKey,
            header: true,
            child: groupWidget?.call(group) ??
                Container(
                  color: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
                  child: Text(
                    groupTitle!(group),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ).merge(groupTextStyle),
                  ),
                ),
          ),
        ),
      );

  Widget buildItems() => SliverList(
        delegate: SliverChildBuilderDelegate(
          addAutomaticKeepAlives: true,
          childCount: items.length,
          addSemanticIndexes: false,
          (context, index) => Builder(builder: (context) {
            return Column(
              children: [
                index > 0 ? divider : null,
                IndexedSemantics(
                  index: groupIndex + index,
                  child: Semantics(
                    onDidGainAccessibilityFocus: () {
                      final scrollBox = _scrollKey.currentContext
                          ?.findRenderObject() as RenderBox?;
                      if (scrollBox == null) return;
                      final scrollBoxTop =
                          scrollBox.localToGlobal(Offset.zero).dy;
                      final scrollBoxBottom =
                          scrollBoxTop + scrollBox.size.height;

                      final itemBox = context.findRenderObject() as RenderBox?;
                      if (itemBox == null) return;

                      final itemHeight = itemBox.size.height;
                      final itemTop = itemBox.localToGlobal(Offset.zero).dy;

                      final maxTop = scrollBoxBottom - itemHeight - 2;

                      final headerBox = _headerKey.currentContext
                          ?.findRenderObject() as RenderBox?;

                      if (headerBox == null) return;
                      final headerHeight = headerBox.size.height;
                      final headerTop = headerBox.localToGlobal(Offset.zero).dy;

                      // final headerBottom = headerTop + headerHeight;

                      final minTop = scrollBoxTop + headerHeight + 2;

                      if (itemTop > maxTop) {
                        final diff = max(minTop, maxTop) - itemTop;

                        _scrollController
                            .jumpTo(_scrollController.offset - diff);
                        return;
                      }

                      if (itemTop >= minTop) {
                        return;
                      }

                      if (headerTop > scrollBoxTop) {
                        return;
                      }

                      // itemBox.markNeedsSemanticsUpdate();
                      // scrollBox.markNeedsSemanticsUpdate();

                      final diff = minTop - itemTop;
                      _scrollController.jumpTo(_scrollController.offset - diff);
                    },
                    child: itemWidget?.call(items[index]) ??
                        PlatformListTile(
                          contentPadding:
                              const EdgeInsets.fromLTRB(16, 8, 0, 8),
                          onTap: () => onTapItem?.call(items[index]),
                          title: (autoTruncateSemanticsLabel
                              ? TruncatedSemanticsText(
                                  itemTitle!(items[index]),
                                  maxLines: itemMaxLines,
                                  style: itemTextStyle,
                                )
                              : Text(
                                  itemTitle!(items[index]),
                                  maxLines: itemMaxLines,
                                  style: itemTextStyle,
                                )),
                          trailing: const DynamicIcon(Icons.chevron_right),
                        ),
                  ),
                ),
              ].whereType<Widget>().toList(),
            );
          }),
        ),
      );
}
