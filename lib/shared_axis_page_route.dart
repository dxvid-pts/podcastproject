import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class SharedAxisPageRoute extends PageRouteBuilder {
  SharedAxisPageRoute(
      {@required Widget page,
      @required SharedAxisTransitionType transitionType})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> primaryAnimation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> primaryAnimation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return SharedAxisTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              transitionType: transitionType,
              child: child,
            );
          },
        );
}
