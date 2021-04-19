import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podcast_player/main.dart';
import 'package:podcast_player/widgets/max_sized_widget.dart';
import 'package:podcast_player/widgets/podcast_grid.dart';

class MainScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final isMobile = watch(layoutProvider).isMobile;

    List<Widget> children = [];

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text('Podcasts'),
              actions: [
                IconButton(
                  tooltip: 'Settings',
                  icon: Icon(Icons.settings_outlined),
                  onPressed: () {
                    /* Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                    builder: (context) => SettingsScreen()));*/
                  },
                ),
              ],
            )
          : null,
      body: MaxSizedWidget(
        maxWidth: 600,
        builder: (width, padding) {
          print(width.toString() + ", " + padding.toString());
          children.insert(0, PodcastGrid(crossAxisCount: (width / 100).round()));
          return ListView.builder(
            itemCount: children.length,
            padding: EdgeInsets.symmetric(horizontal: padding),
            itemBuilder: (context, index) => children[index],
          );
        },
      ),
    );
  }
}
