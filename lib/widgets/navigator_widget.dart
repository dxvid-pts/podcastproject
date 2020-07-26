import 'package:flutter/material.dart';

import '../screens/main_screen.dart';

class NavigationRoutes {
  static const String root = '/';
  static const String second = '/second';
  static const String third = '/third';

  static Widget buildRoute(final String route, {int index = 0}) {
    print('a');
    switch (route) {
      case root:
        if (index == 0)
          print('x');
        else
          print('y');
        return index == 0 ? MainScreen() : SecondScreen();
      case second:
        return SecondScreen();
      case third:
        return ThirdScreen();
      default:
        //Error 404
        return ThirdScreen();
    }
  }
}

class NavigatorWidget extends StatelessWidget {
  NavigatorWidget({Key key, this.route = NavigationRoutes.root, this.index = 0})
      : super(key: key);
  final String route;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: route,
      onGenerateRoute: (routeSettings) {
        print(routeSettings.name);
        return MaterialPageRoute(
          builder: (context) =>
              NavigationRoutes.buildRoute(routeSettings.name, index: index),
        );
      },
    );
  }
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('First Screen')),
      body: Center(
          child: RaisedButton(
        child: Text(
          'Index 0: Home',
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ThirdScreen()),
          );
        },
      )),
    );
  }
}

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Second Screen'));
  }
}

class ThirdScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Third Screen')),
      body: Center(child: Text('Third Screen')),
    );
  }
}
