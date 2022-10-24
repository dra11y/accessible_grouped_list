import 'dart:io';

import 'package:flutter/material.dart';

abstract class PlatformWidget<C extends Widget, M extends Widget>
    extends StatelessWidget {
  static bool? forceMaterial;
  static bool? forceCupertino;

  const PlatformWidget({Key? key}) : super(key: key);

  C buildCupertinoWidget(BuildContext context);

  M buildMaterialWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final isCupertino = PlatformWidget.forceMaterial != true &&
        (PlatformWidget.forceCupertino == true ||
            Platform.isIOS ||
            Platform.isMacOS);
    return isCupertino
        ? buildCupertinoWidget(context)
        : buildMaterialWidget(context);
  }
}
