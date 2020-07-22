import 'package:flutter/material.dart';
import 'package:podcast_player/analyzer.dart';
import 'package:podcast_player/main.dart';
import 'package:podcast_player/utils.dart';
import 'package:podcast_player/widgets/episode_list_tile.dart';

class DownloadedEpisodesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (_, int index) {
        final indexAudioUrl = episodeDownloadInfo.keys.toList()[index];

        for (Podcast podcast in podcasts.values)
          for (String episodeUrl in podcast.episodes)
            if (episodeUrl == indexAudioUrl)
              return EpisodeListTile(
                episode: episodes[episodeUrl],
                leading: Image(
                  image: getImageProvider(podcast.img),
                ),
              );

        return Text(indexAudioUrl);
      },
      itemCount: episodeDownloadInfo.keys.length,
    );
  }
}
