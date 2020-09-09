import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podcast_player/analyzer.dart';
import 'package:podcast_player/main.dart';
import 'package:podcast_player/utils.dart';
import 'package:podcast_player/widgets/episode_list_tile.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  StreamSubscription<String> listener;

  @override
  void initState() {
    listener = updateStream.stream.listen((_) {
      setState(() {});
    });
    historyNotifier.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = getHistory();
    final sortedKeys = history.keys.toList()..sort((a, b) => b.compareTo(a));

    return history.isEmpty
        ? Center(
            child: Text('No History yet'),
          )
        : ListView.builder(
            itemBuilder: (_, int index) {
              final key = sortedKeys[index];

              return HistoryDividedPart(
                eps: history[key],
                dateTime: dateTimeToDayString(key, alwaysIncludeYear: true),
              );
            },
            itemCount: sortedKeys.length,
          );
  }
}

class HistoryDividedPart extends StatelessWidget {
  final List<String> eps;
  final String dateTime;

  const HistoryDividedPart({Key key, this.eps, this.dateTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Divider(),
        Padding(
          padding: const EdgeInsets.only(bottom: 6, top: 13),
          child: Text(
            dateTime,
            style: GoogleFonts.lexendDeca(fontSize: 14.4),
          ),
        ),
        //Divider(),
        for (Episode e
            in eps.map((e) => episodes[e]).where((element) => element != null))
          EpisodeListTile(
            episode: e,
            leading: true,
          ),
      ],
    );
  }
}
