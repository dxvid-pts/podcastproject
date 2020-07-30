import 'package:flutter/material.dart';
import 'package:podcast_player/analyzer.dart';
import 'package:podcast_player/main.dart';
import 'package:podcast_player/utils.dart';
import 'package:podcast_player/widgets/episode_list_tile.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getHistory(),
      builder: (BuildContext context, AsyncSnapshot<List<History>> snapshot) {
        if (snapshot.hasData) {
          Map<String, List<Episode>> daysWithEpisodes = Map();

          snapshot.data.forEach((history) {
            try {
              Episode episode = episodes[history.episodeAudioUrl];

              final datetimeString = dateTimeToDayString(history.dateTime);

              if (daysWithEpisodes.containsKey(datetimeString))
                daysWithEpisodes.update(
                  datetimeString,
                  (list) => list..add(episode),
                );
              else
                daysWithEpisodes.putIfAbsent(datetimeString, () => [episode]);
            } catch (e) {
              print(e);
            }
          });

          return ListView.builder(
            itemBuilder: (_, int index) {
              final key = daysWithEpisodes.keys.toList()[index];

              return HistoryDividedPart(
                episodes: daysWithEpisodes[key],
                dateTime: key.split('-'),
              );
            },
            itemCount: daysWithEpisodes.keys.length,
          );
        } else
          return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class HistoryDividedPart extends StatelessWidget {
  final List<Episode> episodes;
  final List<String> dateTime;

  const HistoryDividedPart({Key key, this.episodes, this.dateTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(episodes.toString());
    return Column(
      children: [
        Divider(),
        Text(dateTime.toString()),
        Divider(),
        for (Episode e in episodes.where((element) => element != null))
          EpisodeListTile(
            episode: e,
            leading:true,
          ),
      ],
    );
  }
}

String dateTimeToDayString(final DateTime d) {
  return '${d.day}-${d.month}-${d.year}';
}
