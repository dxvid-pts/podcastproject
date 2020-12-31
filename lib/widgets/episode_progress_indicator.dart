import 'package:flutter/material.dart';

const double size = 22;
const Color progressedColor = const Color(0x44000000);
const Color progressedColorDark = const Color(0x29FFFFFF);
const Color startColor = const Color(0x66000000);
const Color startColorDark = const Color(0x66FFFFFF);

class EpisodeProgressIndicator extends StatelessWidget {
  final double value;
  final Widget constantChild;

  const EpisodeProgressIndicator({Key key, this.value, this.constantChild})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (value == 0)
      return Icon(
        Icons.play_circle_outline,
        size: size + 7,
        color: Theme.of(context).brightness == Brightness.dark
            ? startColorDark
            : startColor,
      );
    return Stack(
      alignment: Alignment.center,
      children: [
        constantChild,
        SizedBox(
          height: size,
          width: size,
          child: CircularProgressIndicator(
            value: value >= 1 ? 0 : value,
            strokeWidth: 2.3,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? progressedColorDark
                : progressedColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).brightness == Brightness.light
                  ? Colors.blue
                  : Colors.white.withOpacity(0.5),
            ),
          ),
        ),
        if (value >= 1)
          Padding(
            padding:
                const EdgeInsets.only(left: size / 2 - 2, top: size / 2 - 2),
            child: Icon(
              Icons.done,
              size: 28,
              color: Theme.of(context).cardColor,
            ),
          ),
        if (value >= 1)
          Padding(
            padding:
                const EdgeInsets.only(left: size / 2 + 2, top: size / 2 + 2),
            child: Icon(
              Icons.done,
              size: 20,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.green
                  : Colors.greenAccent,
            ),
          ),
      ],
    );
  }
}
