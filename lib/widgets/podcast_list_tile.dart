import 'package:flutter/material.dart';
import 'package:podcast_player/analyzer/utils.dart';
import 'package:podcast_player/widgets/image_card.dart';

class PodcastListTile extends StatelessWidget {
  const PodcastListTile({required this.podcast, this.radius = 7});

  final Podcast podcast;
  final double radius;

  @override
  Widget build(BuildContext context) => ImageCard(
        child: podcast.img == null ? Container() : Image.network(podcast.img!),
        tooltip: podcast.title,
        onTap: () => print(podcast.title),
        radius: radius,
      );
}
