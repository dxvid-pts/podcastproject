import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:podcast_player/screens/podcast_overview_screen.dart';
import 'package:podcast_player/utils.dart';
import '../analyzer.dart';
import '../shared_axis_page_route.dart';

const double size = 110;

class PodcastListTile extends StatelessWidget {
  final Podcast podcast;

  const PodcastListTile({Key key, this.podcast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: podcast.img,
      child: Tooltip(
        message: shortName(podcast.title),
        child: PodcastListTileBase(
          child: Ink.image(
            image: getImageProvider(podcast.img),
            fit: BoxFit.cover,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(SharedAxisPageRoute(
                    page: PodcastOverviewScreen(
                      feedUrl: podcast.url,
                    ),
                    transitionType: SharedAxisTransitionType.scaled));

                /*Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PodcastOverviewScreen(
                              feedUrl: podcast.url,
                            )),
                  );*/
              },
            ),
          ),
        ),
      ),
    );
  }
}

class PodcastListTileBase extends StatelessWidget {
  final Widget child;

  const PodcastListTileBase({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(
        height: size,
        width: size,
        child: child,
      ),
    );
  }
}
