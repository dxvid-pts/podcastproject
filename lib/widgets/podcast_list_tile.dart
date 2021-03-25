import 'package:flutter/material.dart';

const double size = 110;

class PodcastListTile extends StatelessWidget {
  final Widget child;
  final String tooltip;
  final Function onTap;

  const PodcastListTile(
      {required this.child, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const double radius = 7;
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

class PodcastListTileBase extends StatelessWidget {
  final Widget child;

  const PodcastListTileBase({required this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print("aaaaaa");
      },
      child: Card(
        margin: const EdgeInsets.all(0),
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: SizedBox(
          height: size,
          width: size,
          child: child,
        ),
      ),
    );
  }
}
