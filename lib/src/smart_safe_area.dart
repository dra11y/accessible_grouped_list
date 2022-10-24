import 'dart:io';

import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class SmartSafeArea extends StatelessWidget {
  const SmartSafeArea({
    super.key,
    required this.child,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.minimum = EdgeInsets.zero,
    this.maintainBottomViewPadding = false,
  });

  static final isNativeOrientationSupported =
      Platform.isAndroid || Platform.isIOS;

  final Widget child;
  final bool? top;
  final bool? left;
  final bool? right;
  final bool? bottom;
  final EdgeInsets minimum;
  final bool maintainBottomViewPadding;

  @override
  Widget build(BuildContext context) {
    return isNativeOrientationSupported
        ? NativeDeviceOrientationReader(
            builder: (context) {
              final orientation =
                  NativeDeviceOrientationReader.orientation(context);
              return SafeArea(
                key: key,
                top: top ?? true,
                left: left ??
                    orientation == NativeDeviceOrientation.landscapeLeft,
                right: right ??
                    orientation == NativeDeviceOrientation.landscapeRight,
                bottom: bottom ?? false,
                minimum: minimum,
                maintainBottomViewPadding: maintainBottomViewPadding,
                child: child,
              );
            },
          )
        : SafeArea(
            key: key,
            top: top ?? true,
            left: left ?? true,
            right: right ?? true,
            bottom: bottom ?? false,
            minimum: minimum,
            maintainBottomViewPadding: maintainBottomViewPadding,
            child: child,
          );
  }
}
