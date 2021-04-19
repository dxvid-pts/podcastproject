import 'package:flutter/material.dart';

typedef OnLongPressCallback(TapDownDetails position);

late TapDownDetails _lastPos;

class PositionedTapDetector extends StatelessWidget {
  const PositionedTapDetector({required this.onLongPress, required this.child});

  final Widget child;

  final OnLongPressCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      onTapDown: (details) => _lastPos = details,
      onLongPress: () => onLongPress(_lastPos),
      onSecondaryTap: () => onLongPress(_lastPos),
    );
  }
}