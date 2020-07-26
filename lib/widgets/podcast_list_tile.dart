import 'package:flutter/material.dart';
import 'package:podcast_player/utils.dart';
import 'package:podcast_player/widgets/skeleton_widget.dart';
import '../analyzer.dart';

const double size = 110;

enum PodcastListTileType { IMG, SKELETON, ADD }

class PodcastListTile extends StatelessWidget {
  final Podcast podcast;
  final Function onTap;
  final PodcastListTileType type;

  const PodcastListTile(
      {Key key, this.podcast, this.onTap, this.type = PodcastListTileType.IMG})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case PodcastListTileType.IMG:
        return Hero(
          tag: podcast.url,
          child: Tooltip(
            message: podcast.title.length >= 42
                ? podcast.title.substring(0, 42) + '...'
                : podcast.title,
            child: Ink.image(
              image: getImageProvider(podcast.img),
              fit: BoxFit.cover,
              child: InkWell(
                onTap: onTap,
              ),
            ),
          ),
        );
      case PodcastListTileType.SKELETON:
        return PodcastListTileBase(
            child: Skeleton(
          greyscale: 0.033,
        ));
      case PodcastListTileType.ADD:
        return Tooltip(
          message: 'Add Podcast',
          child: PodcastListTileBase(
            child: InkWell(
              onTap: onTap,
              child: Center(
                child: Icon(Icons.add),
              ),
            ),
          ),
        );
      //Delete: when Null-safety
      default:
        return Container();
    }
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
