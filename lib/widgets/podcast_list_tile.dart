import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:podcast_player/utils.dart';
import '../analyzer.dart';
import '../screens/podcast_overview_screen.dart';
import '../shared_axis_page_route.dart';

const double size = 110;

class PodcastListTile extends StatelessWidget {
  final Podcast podcast;

  const PodcastListTile({Key key, @required this.podcast}) : super(key: key);

  /*CachedNetworkImage(
          imageUrl: podcast.img,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(value: downloadProgress.progress,valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),*/

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: podcast.url,
      child: Tooltip(
        message: podcast.title.length >= 42
            ? podcast.title.substring(0, 42) + '...'
            : podcast.title,
        child: Card(
          margin: const EdgeInsets.all(0),
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Container(
            height: size,
            width: size,
            child: Ink.image(
              image: getImageProvider(podcast.img),
              //NetworkImage(podcast.img),
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
      ),
    );
  }
}
