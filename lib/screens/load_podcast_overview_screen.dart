import 'package:flutter/material.dart';
import 'package:podcast_player/screens/podcast_overview_screen.dart';

import '../utils.dart';

class LoadPodcastScreen extends StatelessWidget {
  final Future<Podcast> podcastFuture;

  const LoadPodcastScreen({Key key, this.podcastFuture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: podcastFuture,
      builder: (BuildContext context, AsyncSnapshot<Podcast> snapshot) {
        if (snapshot.hasData)
          return PodcastOverviewScreen(feedUrl: snapshot.data.url);
        else if (snapshot.hasError) {
          return Container(
            color: Colors.white,
            child: Text('Error'),
          );
        } else
          return Scaffold(
            appBar: AppBar(
              title: Text('Loading Podcast...'),
            ),
          );
      },
    );
  }
}
