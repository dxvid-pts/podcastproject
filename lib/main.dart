import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podcast_player/screens/main_screen.dart';

import 'analyzer/utils.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
  WidgetsFlutterBinding.ensureInitialized();
  updateData();
}

final layoutProvider = StateNotifierProvider((ref) => LayoutNotifier());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LayoutBuilder(builder: (context, constraints) {
        context.read(layoutProvider).setWidth(constraints.maxWidth);
        return MainScreen();
      }),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Scaffold(
      appBar: AppBar(
        title: Text("widget.title"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(),
          ElevatedButton(
            child: Text("watch(podcastsProvider.state).length.toString()"),
            onPressed: () {
              //context.read(podcastsProvider).update();
              updateData();
            },
          ),
          ElevatedButton(
            child: Text("test"),
            onPressed: () {
              podcastProvider.test();
              //podcastProvider.test();
            },
          ),
          SizedBox(
            height: 400,
            child: StreamBuilder<Set<Podcast>>(
                stream: podcastProvider.podcasts,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null)
                    return Text("no data");
                  //print(snapshot.data!.first.episodesStream);
                  print("a");
                  return StreamBuilder<Set<Episode>>(
                      stream: snapshot.data!.first.episodesStream,
                      builder: (context, _snapshot) {
                        if (!_snapshot.hasData) return Text("_no data");
                        if (_snapshot.data == null) return Text("agd");
                        return ListView(
                          children: _snapshot.data!
                              .map((e) => Text(e.title))
                              .toList(),
                        );
                      });
                }),
          ),
          LinearProgressIndicator(),
        ],
      ),
    );
  }
}
