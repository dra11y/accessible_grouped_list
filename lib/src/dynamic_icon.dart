import 'package:flutter/material.dart';

class DynamicIcon extends StatelessWidget {
  const DynamicIcon(this.icon, {Key? key}) : super(key: key);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final height = (Theme.of(context).iconTheme.size ?? 24) *
        MediaQuery.textScaleFactorOf(context);
    return Container(
      // decoration:
      //     BoxDecoration(border: Border.all(color: Colors.red, width: 2)),
      height: height,
      child: LayoutBuilder(
          builder: (context, constraint) => Icon(
                icon,
                size: constraint.biggest.height,
              )),
    );
  }
}
