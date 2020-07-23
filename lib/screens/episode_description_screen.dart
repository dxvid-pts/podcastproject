import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:podcast_player/screens/podcast_overview_screen.dart';
import 'package:podcast_player/utils.dart';
import 'package:podcast_player/widgets/download_icon_widget.dart';
import 'package:podcast_player/widgets/playlist_modal.dart';

import '../analyzer.dart';
import '../main.dart';

class EpisodeDescriptionScreen extends StatelessWidget {
  final Episode episode;

  const EpisodeDescriptionScreen({Key key, this.episode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final podcast = podcasts[episode.podcastUrl];

    return Scaffold(
      appBar: AppBar(
        title: Text(episode.title),
      ),
      body: ListView(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PodcastOverviewScreen(feedUrl: podcast.url),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image(
                        height: 55,
                        image: getImageProvider(
                            podcast.img), //fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(podcast.title),
                      Text(podcast.author),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (episode.audioUrl != null)
            Row(
              children: [
                DownloadIconButton(episodeAudioUrl: episode.audioUrl),
                IconButton(
                  tooltip: 'Add to Playlist',
                  icon: Icon(Icons.playlist_add),
                  onPressed: () {
                    showModalBottomSheet(
                        useRootNavigator: true,
                        context: context,
                        builder: (context) {
                          return PlaylistModal(episode: episode);
                        });
                  },
                ),
                PlayPause(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: ValueListenableBuilder(
                      builder: (_, int value, __) {
                        return LinearProgressIndicator(
                          value: value > episode.duration.inSeconds
                              ? 1
                              : value / episode.duration.inSeconds,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                          backgroundColor: Colors.grey.withOpacity(0.2),
                        );
                      },
                      valueListenable: episodeStates[episode.audioUrl],
                    ),
                  ),
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

class PlayPause extends StatefulWidget {
  @override
  _PlayPauseState createState() => _PlayPauseState();
}
//TODO: FIX Functionality
class _PlayPauseState extends State<PlayPause> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Play/Pause',
      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
      onPressed: () {
        setState(() {
          isPlaying = !isPlaying;
        });
      },
    );
  }
}
