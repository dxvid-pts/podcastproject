import 'package:flutter/material.dart';

import 'max_sized_widget.dart';

class WebLayout extends StatelessWidget {
  final Widget child;

  const WebLayout({required this.child});

  @override
  Widget build(BuildContext context) =>
      Center(child: MaxSizedWidget(maxWidth: 600, child: child));
}
