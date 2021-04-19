import 'package:flutter/material.dart';

typedef Widget MaxSizedBuilder(double width, padding);

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
        final double padding = (constraints.maxWidth - maxWidth) / 2;

        if (constraints.maxWidth > maxWidth)
          return builder != null ? builder!(maxWidth, padding) : _child;
        else
          return builder != null ? builder!(constraints.maxWidth, 0) : _child;
      },
    );
  }
}