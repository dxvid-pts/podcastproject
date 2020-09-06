import 'package:flutter/material.dart';

import 'max_sized_widget.dart';

class WebLayout extends StatelessWidget {
  final Widget child;

  const WebLayout({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Center(child: MaxSizedWidget(maxWidth: 600, child: child));
}
