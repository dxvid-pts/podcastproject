import 'package:flutter/material.dart';
import 'package:podcast_player/analyzer/utils.dart';
import 'package:podcast_player/widgets/podcast_list_tile.dart';
import 'package:podcast_player/widgets/positioned_tap_detector.dart';

enum PopupMenuItemType { DONE, PLAYLIST }

class EpisodeListTile extends StatelessWidget {
  final Episode episode;
  final bool leading;

  const EpisodeListTile({required this.episode, this.leading = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: PositionedTapDetector(
        onLongPress: (position) {
          showMenu(
            useRootNavigator: true,
            position: RelativeRect.fromLTRB(
                position.globalPosition.dx, position.globalPosition.dy, 50, 0),
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
            /*switch (type) {
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
            }*/
          });
        },
        child: ListTile(
          leading: leading
              ? SizedBox(height: 56, width: 56, child: PodcastListTile(podcast: episode.podcast, radius: 4))
              : null,
          contentPadding: EdgeInsets.only(
            left: leading == false ? 22 : 12,
            right: 22,
            top: 6, //leading == null ? 6 : 0,
            bottom: 6, //leading == null ? 6 : 0,
          ),
          title: Text(
            episode.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('episode.dateString'),
                SeparatorWidget(),
               /* Text(episode.duration == null
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
                  ),*/
              ],
            ),
          ),
         /* trailing:  IconButton(
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
          ),*/
          onTap: () {
          /*  Navigator.of(context).push(SharedAxisPageRoute(
                page: EpisodeDescriptionScreen(
                  episode: episode,
                  popBack: !leading,
                ),
                transitionType: SharedAxisTransitionType.horizontal));*/
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
      color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
      size: 5,
    ),
  );
}