import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  final Widget child;
  final String tooltip;
  final Function onTap;
  final double radius;

  const ImageCard({required this.child, required this.tooltip, required this.onTap, this.radius = 7});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: child,
          ),
          Material(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
              side: BorderSide(
                color: Color(0xFFD8D8D8),
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(radius),
              onTap: () => onTap(),
            ),
          ),
        ],
      ),
    );
  }
}