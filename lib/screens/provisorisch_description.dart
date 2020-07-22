import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:podcast_player/main.dart';
import 'package:podcast_player/utils.dart';

class ProvisorischeDescription extends StatelessWidget {
  final Episode episode;

  const ProvisorischeDescription({Key key, this.episode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(episode.title),
        actions: [
          IconButton(
            onPressed: () => openDescription.value = null,
            icon: Icon(Icons.close),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Html(
          data: episode.description,
          onLinkTap: (url) => openLinkInBrowser(context, url),
        ),
      ),
    );
  }
}
