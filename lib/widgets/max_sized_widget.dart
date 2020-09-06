import 'package:flutter/material.dart';

class MaxSizedWidget extends StatelessWidget {
  final double maxWidth;
  final Widget child;

  const MaxSizedWidget({Key key, @required this.maxWidth, @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > maxWidth)
          return SizedBox(
            width: maxWidth,
            child: child,
          );
        else
          return child;
      },
    );
  }
}
