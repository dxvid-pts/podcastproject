import 'package:flutter/material.dart';

class NavigatorPage extends StatelessWidget {
  const NavigatorPage(
      {Key key, @required this.child, @required this.navigatorKey})
      : super(key: key);

  final Widget child;
  final GlobalKey navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) => child,
        );
      },
      // ),
    );
  }
}
