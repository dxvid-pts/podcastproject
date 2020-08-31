import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podcast_player/screens/settings_screen.dart';
import 'package:podcast_player/widgets/episode_list_tile.dart';
import 'package:podcast_player/widgets/text_dialog_widget.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Podcasts'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: Icon(PodcastIcons.vector),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          ),
        ],
      ),
      body: StreamBuilder<String>(
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
                  padding: const EdgeInsets.only(left: 10, bottom: 6, top: 13),
                  child: Text(
                    'New Episodes:',
                    style: GoogleFonts.lexendDeca(fontSize: 14.4),
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
