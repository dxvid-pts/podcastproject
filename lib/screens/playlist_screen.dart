import 'package:flutter/material.dart';
import 'package:podcast_player/utils.dart';
import 'package:podcast_player/widgets/episode_list_tile.dart';

import '../analyzer.dart';
import '../main.dart';

class PlaylistScreen extends StatelessWidget {
  final String playlistName;

  const PlaylistScreen({Key key, @required this.playlistName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(playlistName),
      ),
      body: ListView(
        children: [
          for (Episode episode in getPlaylistContent(playlistName))
            EpisodeListTile(
              leading: Image(
                image: getImageProvider(podcasts[episode.podcastUrl].img),
              ),
              episode: episode,
            ),
        ],
      ),
    );
  }
}
