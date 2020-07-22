import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:podcast_player/utils.dart';
import 'package:podcast_player/widgets/download_icon_widget.dart';
import 'package:podcast_player/widgets/episode_progress_indicator.dart';
import 'package:podcast_player/widgets/player.dart';

import '../main.dart';

class EpisodeDescriptionScreen extends StatelessWidget {
  final Episode episode;

  const EpisodeDescriptionScreen({Key key, this.episode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(episode.title),
      ),
      body: ListView(
        children: [
          Text('PODCAST INFO'),
          if (episode.audioUrl != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DownloadIconButton(episodeAudioUrl: episode.audioUrl),
                IconButton(
                  tooltip: 'Play/Pause',
                  icon: ValueListenableBuilder(
                    builder: (BuildContext context, int value, Widget child) {
                      return EpisodeProgressIndicator(
                        value: value > episode.duration.inSeconds
                            ? 1
                            : value / episode.duration.inSeconds,
                        constantChild: child,
                      );
                    },
                    valueListenable: episodeStates[episode.audioUrl],
                    child: arrowIcon,
                  ),
                  onPressed: () {
                    currentlyPlaying.value = episode;
                  },
                ),
              ],
            ),
          Html(
            data: episode.description,
            onLinkTap: (url) => openLinkInBrowser(context, url),
          ),
        ],
      ),
    );
  }
}
