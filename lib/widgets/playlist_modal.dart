import 'package:flutter/material.dart';
import 'package:podcast_player/utils.dart';
import 'package:podcast_player/widgets/text_dialog_widget.dart';

import '../analyzer.dart';

class PlaylistModal extends StatelessWidget {
  final Episode episode;

  const PlaylistModal({Key key, @required this.episode}) : super(key: key);

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return TextDialogWidget(
            title: 'Create new playlist',
            hint: 'Playlist name',
            okButtonText: 'Create',
            onSubmit: (text) {
              addToPlaylist(episode, text);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Save Episode...'),
              TextButton.icon(
                  onPressed: () {
                    _displayDialog(context);
                  },
                  icon: Icon(Icons.add),
                  label: Text('New Playlist'))
            ],
          ),
        ),
        Divider(),
        for (String playlistName in listPlaylists())
          PlaylistListTile(
            episode: episode,
            playlistName: playlistName,
          ),
      ],
    );
  }
}

class PlaylistListTile extends StatefulWidget {
  final Episode episode;
  final String playlistName;

  const PlaylistListTile(
      {Key key, @required this.episode, @required this.playlistName})
      : super(key: key);

  @override
  _PlaylistListTileState createState() => _PlaylistListTileState();
}

class _PlaylistListTileState extends State<PlaylistListTile> {
  bool contains = false;

  @override
  void initState() {
    contains =
        isEpisodeInPlaylist(widget.episode, widget.playlistName) ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.playlistName),
      value: contains,
      checkColor: Colors.blueAccent,
      onChanged: (bool value) {
        if (contains) {
          removeFromPlaylist(widget.episode, widget.playlistName);
        } else
          addToPlaylist(widget.episode, widget.playlistName);
        setState(() {
          contains = !contains;
        });
      },
    );
  }
}
