import 'package:flutter/material.dart';

class BodyLayoutWidget extends StatelessWidget {
  final Widget appBar;
  final Widget body;

  const BodyLayoutWidget({Key key, @required this.appBar, @required this.body})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        appBar,
        Expanded(
          child: body,
        ),
       // SizedBox(height: minHeight),
      ],
    );
  }
}
