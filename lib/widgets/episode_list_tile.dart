import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:podcast_player/screens/episode_description_screen.dart';
import 'package:podcast_player/screens/podcast_overview_screen.dart';
import 'package:podcast_player/utils.dart';
import 'package:podcast_player/widgets/download_icon_widget.dart';
import 'package:podcast_player/widgets/episode_progress_indicator.dart';
import 'package:podcast_player/widgets/player.dart';
import 'package:podcast_player/main.dart';
import 'package:positioned_tap_detector/positioned_tap_detector.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import '../shared_axis_page_route.dart';

const seperatorWidget = Padding(
  padding: const EdgeInsets.symmetric(horizontal: 5),
  child: Icon(
    Icons.brightness_1,
    color: const Color(0x66000000),
    size: 5,
  ),
);

class EpisodeListTile extends StatelessWidget {
  final Episode episode;
  final Widget leading;

  const EpisodeListTile({Key key, @required this.episode, this.leading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String date = '<NO DATE>';
    if (episode.date != null) {
      Duration diff = DateTime.now().difference(episode.date);

      if (diff.inHours < 24)
        date = '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
      else if (diff.inDays <= 7)
        date = '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
      else
        date = '${episode.date.day} ${intToMonth(episode.date.month)}';
      /* else if (diff.inDays >= 365) {
        final years = (diff.inDays / 365).floor();
        date = '$years year${years > 1 ? 's' : ''} ago';
      } else if (diff.inDays >= 30.4) {
        final months = (diff.inDays / 30.4).floor();
        date = '$months month${months > 1 ? 's' : ''} ago';
      } else
        date = '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';*/
    }
    return Card(
      child: PositionedTapDetector(
        onLongPress: (position) {
          showMenu(
            position: RelativeRect.fromLTRB(
                position.relative.dx, position.global.dy, 50, 0),
            //onSelected: () => setState(() => imageList.remove(index)),
            items: <PopupMenuEntry>[
              //PopupMenuButton(),
              PopupMenuItem(
                value: 0,
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.done,
                      color: Colors.green,
                    ),
                    SizedBox(width: 5),
                    Text("Mark as played"),
                  ],
                ),
              )
            ],
            context: context,
          );
        },
        child: ListTile(
          leading: leading == null
              ? null
              : Tooltip(
                  message:
                      "Open '${shortName(podcasts[episode.podcastUrl].title)}'",
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(SharedAxisPageRoute(
                        page: PodcastOverviewScreen(
                          feedUrl: podcasts[episode.podcastUrl].url,
                        ),
                        transitionType: SharedAxisTransitionType.scaled)),
                    child: leading,
                  ),
                ),
          contentPadding: EdgeInsets.only(
            left: leading == null ? 22 : 12,
            right: 22,
            top: 6, //leading == null ? 6 : 0,
            bottom: 6, //leading == null ? 6 : 0,
          ),
          title: Text(episode.title == null ? '<NO TITLE>' : episode.title),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(date),
                seperatorWidget,
                Text(episode.duration == null
                    ? '<NO DURATION>'
                    : '${episode.duration.inMinutes} minutes'),
                if (episodeDownloadStates.containsKey(episode.audioUrl) &&
                    episodeDownloadStates[episode.audioUrl] == 100)
                  Row(
                    children: [
                      seperatorWidget,
                      DownloadIconButton(
                        episodeAudioUrl: episode.audioUrl,
                        showGreaterZeroOnly: true,
                        iconSize: 15,
                      ),
                    ],
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
                  //iconSize: 24,
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
          onTap: () {
            Navigator.of(context).push(SharedAxisPageRoute(
                page: EpisodeDescriptionScreen(episode: episode),
                transitionType: SharedAxisTransitionType.horizontal));
            /*Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      EpisodeDescriptionScreen(episode: episode)),
            );*/
          },
        ),
      ),
    );
  }
}

void callback(String s, DownloadTaskStatus status, int progress) {
  print('$s, ${status.toString()}, $progress');
}
