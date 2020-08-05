import 'package:flutter/material.dart';
import 'package:podcast_player/main.dart';
import 'package:podcast_player/utils.dart';
import 'package:podcast_player/widgets/episode_list_tile.dart';

class DownloadedEpisodesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      builder: (_, __, ___) {
        return ListView.builder(
          itemBuilder: (_, int index) {
            final indexAudioUrl = episodeDownloadInfo.keys.toList()[index];

            for (Episode episode in episodes.values)
              if (episode.audioUrl == indexAudioUrl)
                return EpisodeListTile(
                  episode: episode,
                  leading: true,
                );

            return Text(indexAudioUrl);
          },
          itemCount: episodeDownloadInfo.keys.length,
        );
      },
      valueListenable: downloadedEpisodes,
    );
  }
}
