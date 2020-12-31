import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podcast_player/screens/settings_screen/settings_screen.dart';
import 'package:podcast_player/widgets/episode_list_tile.dart';
import 'package:podcast_player/widgets/text_dialog_widget.dart';
import 'package:podcast_player/widgets/web_layout.dart';
import '../analyzer.dart';
import '../podcast_icons_icons.dart';
import 'package:podcast_player/utils.dart';
import 'package:podcast_player/widgets/podcast_list_tile.dart';

import '../main.dart';
import 'load_podcast_overview_screen.dart';

class MainScreen extends StatelessWidget {
  final ScrollController controller;

  const MainScreen({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      builder: (context, _isMobile, body) {
        return Scaffold(
          appBar: !_isMobile
              ? null
              : AppBar(
                  title: Text('Podcasts'),
                  actions: [
                    IconButton(
                      tooltip: 'Settings',
                      icon: Icon(PodcastIcons.vector),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                                builder: (context) => SettingsScreen()));
                      },
                    ),
                  ],
                ),
          body: _isMobile ? body : WebLayout(child: body),
        );
      },
      child: StreamBuilder<String>(
          stream: updateStream.stream,
          builder: (_, __) {
            final widgets = <Widget>[
              /* StreamBuilder(
                    stream: updateStream.stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active)
                        return Container();
                      else
                        return LinearProgressIndicator();
                    },
                  ),*/
              GridView.count(
                primary: false,
                shrinkWrap: true,
                padding: const EdgeInsets.all(5),
                crossAxisCount: 4,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                children: <Widget>[
                  ...podcasts.values
                      .map((p) => PodcastListTile(
                            podcast: p,
                          ))
                      .toList(),
                  Tooltip(
                    message: 'Add Podcast',
                    child: PodcastListTileBase(
                      child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return TextDialogWidget(
                                  title: 'Add Podcast',
                                  labelText: 'Enter RSS-Feed',
                                  hint: 'https://www.domain.com/rss',
                                  okButtonText: 'Add',
                                  onSubmit: (url) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              LoadPodcastScreen(
                                                  podcastFuture:
                                                      podcastFromUrl(url))),
                                    );
                                  },
                                );
                              });
                        },
                        child: Center(
                          child: Icon(Icons.add),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (podcasts.keys.length > 0)
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10, bottom: 6, top: 13, right: 10),
                  child: Row(
                    children: [
                      Text(
                        'New Episodes:',
                        style: GoogleFonts.lexendDeca(fontSize: 14.4),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      ValueListenableBuilder(
                        builder: (context, DateTime dateTime, child) =>
                            StreamBuilder(
                          stream: Stream.periodic(Duration(seconds: 5)),
                          builder: (context, _) {
                            if (dateTime == null) return Container();
                            return Row(
                              children: [
                                child,
                                Text(
                                  dateTime == null
                                      ? '--'
                                      : durationToString(DateTime.now()
                                          .difference(dateTime)),
                                  style: GoogleFonts.lexendDeca(
                                      fontSize: 13,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .color
                                          .withOpacity(0.6)),
                                ),
                              ],
                            );
                          },
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: Icon(Icons.history, size: 14,color: Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white.withOpacity(0.6),),
                        ),
                        valueListenable: offlineDate,
                      ),
                    ],
                  ),
                ),
              for (Episode e in episodes.values
                  .where((episode) => episode.date != null)
                  .toList()
                    ..sort((a, b) => b.date.compareTo(a.date)))
                EpisodeListTile(
                  episode: e,
                  leading: true,
                ),
            ];
            return RefreshIndicator(
              color: Colors.blue,
              onRefresh: () async {
                await loadPodcasts(skipSharedPreferences: true);
              },
              child: ListView.builder(
                controller: controller,
                itemCount: widgets.length,
                itemBuilder: (_, int index) {
                  return widgets[index];
                },
              ),
            );
          }),
      valueListenable: isMobile,
    );
  }
}

/*//Layout: 4x3 -> 12
List<PodcastListTile> generateListTiles(BuildContext context) {
  List<PodcastListTile> tiles = List();
  //TODO int pages = (podcasts.values.length / 12).ceil();

  for (Podcast podcast in podcasts.values)
    tiles.add(
      PodcastListTile(
        podcast: podcast,
        type: PodcastListTileType.IMG,
        onTap: () => Navigator.of(context).push(SharedAxisPageRoute(
            page: PodcastOverviewScreen(
              feedUrl: podcast.url,
            ),
            transitionType: SharedAxisTransitionType.scaled)),
      ),
    );

  var _podcastCount = podcastCount;
  if (_podcastCount == null) _podcastCount = 0;

  for (int index = 0; index < _podcastCount - podcasts.values.length; index++) {
    tiles.add(
      PodcastListTile(type: PodcastListTileType.SKELETON),
    );
  }

  tiles.add(
    PodcastListTile(
      type: PodcastListTileType.ADD,
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return TextDialogWidget(
                title: 'Add Podcast',
                hint: 'RSS-Feed',
                okButtonText: 'Add',
                onSubmit: (url) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoadPodcastScreen(
                            podcastFuture: podcastFromUrl(url))),
                  );
                },
              );
            });
      },
    ),
  );

  return tiles;
}*/
