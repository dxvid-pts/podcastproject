import 'package:flutter/material.dart';
import 'package:podcast_player/screens/library_screen/downloaded_episodes_screen.dart';
import 'package:podcast_player/screens/library_screen/history_screen.dart';
import 'package:podcast_player/screens/library_screen/playlist_overview_screen.dart';
import 'package:podcast_player/screens/settings_screen/settings_screen.dart';
import '../../podcast_icons_icons.dart';
import 'package:podcast_player/main.dart';

class LibraryScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final tabBar = TabBar(
      indicatorColor: Theme.of(context).brightness == Brightness.light ? Colors.blue:Colors.white,
      indicatorSize: TabBarIndicatorSize.label,
      tabs: [
        Tab(text: 'History'),
        Tab(text: 'Downloads'),
        Tab(text: 'Playlists'),
      ],
    );

    return ValueListenableBuilder(
      builder: (context, _isMobile, body) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
              appBar: !_isMobile
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
              body: body),
        );
      },
      child: TabBarView(
        children: [
          HistoryScreen(),
          DownloadedEpisodesScreen(),
          PlaylistOverviewScreen(),
        ],
      ),
      valueListenable: isMobile,
    );
  }
}
