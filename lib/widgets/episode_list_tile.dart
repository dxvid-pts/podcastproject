import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:podcast_player/image_handler.dart';
import 'package:podcast_player/screens/episode_description_screen.dart';
import 'package:podcast_player/screens/podcast_overview_screen.dart';
import 'package:podcast_player/utils.dart';
import 'package:podcast_player/widgets/download_icon_widget.dart';
import 'package:podcast_player/widgets/episode_progress_indicator.dart';
import 'package:podcast_player/widgets/player.dart';
import 'package:podcast_player/main.dart';
import 'package:podcast_player/widgets/playlist_modal.dart';
import 'package:positioned_tap_detector/positioned_tap_detector.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import '../analyzer.dart';
import '../shared_axis_page_route.dart';

enum PopupMenuItemType { DONE, PLAYLIST }

class EpisodeListTile extends StatelessWidget {
  final Episode episode;
  final bool leading;

  const EpisodeListTile({Key key, @required this.episode, this.leading = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: PositionedTapDetector(
        onLongPress: (position) {
          showMenu(
            useRootNavigator: true,
            position: RelativeRect.fromLTRB(
                position.relative.dx, position.global.dy, 50, 0),
            //onSelected: () => setState(() => imageList.remove(index)),
            items: <PopupMenuEntry>[
              //PopupMenuButton(),
              PopupMenuItem<PopupMenuItemType>(
                value: PopupMenuItemType.DONE,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.done),
                    SizedBox(width: 5),
                    Text("Mark as played"),
                  ],
                ),
              ),
              PopupMenuItem<PopupMenuItemType>(
                value: PopupMenuItemType.PLAYLIST,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.playlist_add),
                    SizedBox(width: 5),
                    Text("Add to playlist"),
                  ],
                ),
              ),
            ],
            context: context,
          ).then((type) {
            switch (type) {
              case PopupMenuItemType.DONE:
                saveEpisodeState(
                  episode.audioUrl,
                  episode.duration.inSeconds,
                );
                break;
              case PopupMenuItemType.PLAYLIST:
                showModalBottomSheet(
                    useRootNavigator: true,
                    context: context,
                    builder: (context) {
                      return PlaylistModal(episode: episode);
                    });
                break;
            }
          });
        },
        child: ListTile(
          leading: leading
              ? Tooltip(
                  message:
                      "Open '${shortName(podcasts[episode.podcastUrl].title)}'",
                  child: Card(
                    margin: const EdgeInsets.all(0),
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 1,
                    child: OptimizedImage(
                      url: podcasts[episode.podcastUrl].img,
                      onTap: () =>
                          Navigator.of(context).push(SharedAxisPageRoute(
                              page: PodcastOverviewScreen(
                                feedUrl: podcasts[episode.podcastUrl].url,
                              ),
                              transitionType: SharedAxisTransitionType.scaled)),
                    ),
                  ),
                )
              : null,
          contentPadding: EdgeInsets.only(
            left: leading == null ? 22 : 12,
            right: 22,
            top: 6, //leading == null ? 6 : 0,
            bottom: 6, //leading == null ? 6 : 0,
          ),
          title: Text(
            episode.title == null ? '<NO TITLE>' : episode.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(episode.dateString),
                SeparatorWidget(),
                Text(episode.duration == null
                    ? '<NO DURATION>'
                    : '${episode.duration.inMinutes} minutes'),
                if (episodeDownloadStates.containsKey(episode.audioUrl))
                  ValueListenableBuilder(
                    builder: (_, int _progress, child) {
                      if (_progress > 0)
                        return Row(
                          children: [
                            child,
                            DownloadIcon(
                              progress: _progress,
                              iconSize: 15,
                            ),
                          ],
                        );
                      else
                        return Container();
                    },
                    child: SeparatorWidget(),
                    valueListenable: episodeDownloadStates[episode.audioUrl],
                  ),
              ],
            ),
          ),
          trailing: episode.audioUrl == null
              ? Icon(
                  Icons.error_outline,
                  color: Colors.black.withOpacity(0.4),
                )
              : IconButton(
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
                    child: Icon(
                      Icons.play_arrow,
                      size: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? progressedColorDark
                          : progressedColor,
                    ),
                  ),
                  onPressed: () {
                    currentlyPlaying.value = episode;
                  },
                ),
          onTap: () {
            Navigator.of(context).push(SharedAxisPageRoute(
                page: EpisodeDescriptionScreen(
                  episode: episode,
                  popBack: !leading,
                ),
                transitionType: SharedAxisTransitionType.horizontal));
          },
        ),
      ),
    );
  }
}

class SeparatorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.5),
        child: Icon(
          Icons.brightness_1,
          color: Theme.of(context).textTheme.caption.color,
          size: 5,
        ),
      );
}

void callback(String s, DownloadTaskStatus status, int progress) {
  print('$s, ${status.toString()}, $progress');
}
