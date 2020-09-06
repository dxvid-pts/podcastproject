import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:podcast_player/image_handler.dart';
import 'package:podcast_player/screens/podcast_overview_screen.dart';
import 'package:podcast_player/utils.dart';
import 'package:podcast_player/widgets/download_icon_widget.dart';
import 'package:podcast_player/widgets/playlist_modal.dart';
import 'package:podcast_player/widgets/web_layout.dart';

import '../main.dart';
import '../shared_axis_page_route.dart';

class EpisodeDescriptionScreen extends StatelessWidget {
  final Episode episode;
  final bool popBack;

  const EpisodeDescriptionScreen({
    Key key,
    this.episode,
    this.popBack = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final podcast = podcasts[episode.podcastUrl];

    final body = ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Text(
            episode.title,
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(fontWeight: FontWeight.normal),
          ),
        ),
        InkWell(
          onTap: () {
            if (popBack)
              Navigator.of(context).pop();
            else
              Navigator.of(context).push(SharedAxisPageRoute(
                  page: PodcastOverviewScreen(feedUrl: podcast.url),
                  transitionType: SharedAxisTransitionType.horizontal));
          },
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 55,
                      child: OptimizedImage(
                        url: podcast.img,
                      ), //fit: BoxFit.contain,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
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
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: kIsWeb
            ? WebLayout(child: Text(episode.title))
            : Text(episode.title),
      ),
      body: !kIsWeb ? body : WebLayout(child: body),
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
