import 'package:flutter/material.dart';
import 'package:podcast_player/screens/downloaded_episodes_screen.dart';
import 'package:podcast_player/screens/history_screen.dart';
import 'package:podcast_player/screens/playlist_overview_screen.dart';
import 'package:podcast_player/screens/settings_screen.dart';

import '../podcast_icons_icons.dart';

class LibraryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Podcasts'),
          actions: [
            IconButton(
              tooltip: 'Settings',
              icon: Icon(PodcastIcons.vector),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.blue,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: 'History'),
              Tab(text: 'Downloads'),
              Tab(text: 'Playlists'),
            ],
          ),
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
