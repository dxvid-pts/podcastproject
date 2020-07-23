import 'package:flutter/material.dart';
import 'package:podcast_player/screens/downloaded_episodes_screen.dart';
import 'package:podcast_player/screens/history_screen.dart';
import 'package:podcast_player/screens/playlist_overview_screen.dart';
import 'package:podcast_player/screens/settings_screen.dart';
import 'package:podcast_player/widgets/body_layout_widget.dart';

import '../podcast_icons_icons.dart';
import 'cast_test_screen_remove.dart';

class LibraryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: BodyLayoutWidget(
        appBar: SizedBox(
          height: 56 + 46.0,
          child: AppBar(
            title: Text('Podcasts'),
            actions: [
              IconButton(
                tooltip: 'Cast',
                icon: Icon(Icons.cast),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CastTestScreenRemove()),
                  );
                },
              ),
              /*  IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () {},
              ),*/
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
        ),
        body: TabBarView(
          children: [
            HistoryScreen(),
            DownloadedEpisodesScreen(),
            PlaylistOverviewScreen(),
          ],
        ), /*Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              child: Text('Downloads'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Scaffold(
                            body: DownloadedEpisodesScreen(),
                            appBar: AppBar(
                              title: Text('Downloads'),
                            ),
                          )),
                );
              },
            ),
            RaisedButton(
              child: Text('History'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Scaffold(
                            body: HistoryScreen(),
                            appBar: AppBar(
                              title: Text('History'),
                            ),
                          )),
                );
              },
            ),
          ],
        ),*/
      ),
    );
  }
}
