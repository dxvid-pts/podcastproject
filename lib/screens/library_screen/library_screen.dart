import 'package:flutter/material.dart';
import 'package:podcast_player/screens/library_screen/downloaded_episodes_screen.dart';
import 'package:podcast_player/screens/library_screen/history_screen.dart';
import 'package:podcast_player/screens/library_screen/playlist_overview_screen.dart';
import 'package:podcast_player/screens/settings_screen.dart';
import 'package:flutter/foundation.dart';
import '../../podcast_icons_icons.dart';

class LibraryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabBar = TabBar(
      indicatorColor: Colors.blue,
      indicatorSize: TabBarIndicatorSize.label,
      tabs: [
        Tab(text: 'History'),
        Tab(text: 'Downloads'),
        Tab(text: 'Playlists'),
      ],
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: kIsWeb
            ? tabBar
            : AppBar(
                title: Text('Podcasts'),
                actions: [
                  IconButton(
                    tooltip: 'Settings',
                    icon: Icon(PodcastIcons.vector),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                              builder: (context) => SettingsScreen()));
                    },
                  ),
                ],
                bottom: tabBar,
              ),
        body: TabBarView(
          children: [
            HistoryScreen(),
            DownloadedEpisodesScreen(),
            PlaylistOverviewScreen(),
          ],
        ),
      ),
    );
  }
}
