import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podcast_player/analyzer/utils.dart';
import 'package:podcast_player/main.dart';
import 'package:podcast_player/widgets/episode_list_tile.dart';
import 'package:podcast_player/widgets/last_updated_widget.dart';
import 'package:podcast_player/widgets/max_sized_widget.dart';
import 'package:podcast_player/widgets/podcast_grid.dart';

class MainScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final isMobile = watch(layoutProvider).isMobile;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text('Podcasts'),
              actions: [
                IconButton(
                  tooltip: 'Settings',
                  icon: Icon(Icons.settings_outlined),
                  onPressed: () {
                    /* Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                    builder: (context) => SettingsScreen()));*/
                  },
                ),
              ],
            )
          : null,
      body: StreamBuilder<Set<Episode>>(
        initialData: episodeProvider.currentState.values.toSet(),
        stream: episodeProvider.episodes,
        builder: (context, snapshot) {
          return MaxSizedWidget(
            maxWidth: 600,
            builder: (width, padding) {
              List<Widget> children = !snapshot.hasData || snapshot.data == null
                  ? []
                  : [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10, bottom: 6, top: 13, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'New Episodes:',
                        style: GoogleFonts.lexendDeca(fontSize: 14.4),
                      ),
                      LastUpdatedWidget(),
                    ],
                  ),
                ),
                for(Episode episode in snapshot.data!)
                  EpisodeListTile(episode: episode,leading: true)
              ];

              print(width.toString() + ", " + padding.toString());
              children.insert(0, PodcastGrid(crossAxisCount: (width / 100).round()));
              return ListView.builder(
                itemCount: children.length,
                padding: EdgeInsets.symmetric(horizontal: padding),
                itemBuilder: (context, index) => children[index],
              );
            },
          );
        }
      ),
    );
  }
}
