import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_widget.dart';
import 'smart_safe_area.dart';

class PlatformListTile extends PlatformWidget<CupertinoButton, ListTile> {
  const PlatformListTile({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding,
  });

  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final GestureTapCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;

  // https://stackoverflow.com/questions/57145904/flutter-cupertino-listtile-or-how-to-create-ios-like-settings-menu
  /*
      "The only drawback to this approach is that the button uses pressedOpacity,
      but reducing the default value from 0.4 to 0.65 or something like that will work just fine."
   */

  @override
  CupertinoButton buildCupertinoWidget(BuildContext context) {
    return CupertinoButton(
      pressedOpacity: 0.65,
      borderRadius: const BorderRadius.all(
        Radius.circular(0),
      ),
      padding: contentPadding,
      alignment: Alignment.centerLeft,
      onPressed: onTap,
      child: SmartSafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: title ?? const SizedBox.shrink()),
                trailing,
              ].whereType<Widget>().toList(),
            ),
            Row(
              children: [Expanded(child: subtitle ?? const SizedBox.shrink())],
            )
          ].whereType<Widget>().toList(),
        ),
      ),
    );
  }

  @override
  ListTile buildMaterialWidget(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: contentPadding,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
    );
  }
}
