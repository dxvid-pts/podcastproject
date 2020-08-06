import 'package:flutter/material.dart';
import 'package:podcast_player/analyzer.dart';
import 'package:podcast_player/screens/playlist_screen.dart';

class PlaylistOverviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final list = listPlaylists();

    return list.isEmpty
        ? Center(
            child: Text('No Playlists'),
          )
        : ListView(
            children: [
              for (String playlistName in list)
                ListTile(
                  title: Text(playlistName),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PlaylistScreen(playlistName: playlistName)),
                    );
                  },
                ),
            ],
          );
  }
}
