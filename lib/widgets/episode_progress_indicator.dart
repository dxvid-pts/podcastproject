import 'package:flutter/material.dart';

const double size = 22;
const Color progressedColor = const Color(0x44000000);
const Color startColor = const Color(0x66000000);

const arrowIcon = Icon(
  Icons.play_arrow,
  size: 16,
  color: progressedColor,
);
const completedIcon = Icon(
  Icons.done,
  size: 20,
  color: Colors.green,
);

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
        color: startColor,
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
            backgroundColor: progressedColor,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        if (value >= 1)
          Padding(
            padding:
                const EdgeInsets.only(left: size / 2 - 2, top: size / 2 - 2),
            child: Icon(
              Icons.done,
              size: 28,
              color: Colors.white,
            ),
          ),
        if (value >= 1)
          Padding(
            padding:
                const EdgeInsets.only(left: size / 2 + 2, top: size / 2 + 2),
            child: completedIcon,
          ),
      ],
    );
  }
}
