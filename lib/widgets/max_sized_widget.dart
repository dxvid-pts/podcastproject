import 'package:flutter/material.dart';

typedef Widget MaxSizedBuilder(double width);

class MaxSizedWidget extends StatelessWidget {
  final double maxWidth;
  final Widget? child;
  final MaxSizedBuilder? builder;

  const MaxSizedWidget({required this.maxWidth, this.child, this.builder});

  @override
  Widget build(BuildContext context) {
    final Widget _child = child == null ? Container() : child!;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > maxWidth)
          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: (constraints.maxWidth - maxWidth) / 2),
            child: SizedBox(
              width: maxWidth,
              child: builder != null ? builder!(maxWidth) : _child,
            ),
          );
        else
          return builder != null ? builder!(constraints.maxWidth) : _child;
      },
    );
  }
}
