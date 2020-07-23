import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:podcast_player/screens/settings_screen.dart';
import 'package:podcast_player/widgets/episode_list_tile.dart';
import '../analyzer.dart';
import '../podcast_icons_icons.dart';
import 'cast_test_screen_remove.dart';
import 'package:podcast_player/utils.dart';
import 'package:podcast_player/widgets/body_layout_widget.dart';
import 'package:podcast_player/widgets/podcast_list_tile.dart';

import '../main.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BodyLayoutWidget(
      appBar: AppBar(
        title: Text('Podcasts'),
        actions: [
          IconButton(
            tooltip: 'Cast',
            icon: Icon(Icons.cast),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CastTestScreenRemove()),
              );
            },
          ),
          /*  IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () {},
          ),*/
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
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            print('update  Stream');
            return RefreshIndicator(
              onRefresh: () async {
                await loadPodcasts(skipSharedPreferences: true);
                //updateStream = loadPodcasts(skipSharedPreferences: true).asBroadcastStream();
                // await updateStream.last;
              },
              child: ListView(
                children: <Widget>[
                  StreamBuilder(
                    stream: updateStream.stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active)
                        return Container();
                      else
                        return LinearProgressIndicator();
                    },
                  ),
                  GridView.count(
                    primary: false,
                    shrinkWrap: true,
                    //physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(5),
                    crossAxisCount: 4,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    children: podcasts.values
                        .map((p) => PodcastListTile(
                              podcast: p,
                            ))
                        .toList(),
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Tab(
                        text: 'New episodes',
                      )),
                  /*
                  //TODO:
                  children: new List.generate(this.itemCount,
              (index) => this.itemBuilder(context, index)).toList(),
              https://github.com/flutter/flutter/issues/61297
                   */
                  for (Episode e in episodes.values
                      .where((episode) => episode.date != null)
                      .toList()
                        ..sort((a, b) => b.date.compareTo(a.date)))
                    EpisodeListTile(
                      episode: e,
                      leading: Image(
                        image: getImageProvider(podcasts[e.podcastUrl].img),
                      ),
                    ),
                ],
              ),
            );
          }),
    );
  }
}
