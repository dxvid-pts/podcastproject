import 'dart:core';
import 'package:path_provider/path_provider.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:flutter/foundation.dart';
import 'package:state_notifier/state_notifier.dart';

import 'analyzer.dart';

ValueNotifier<Episode?> currentEpisode = ValueNotifier(null);
ValueNotifier<DateTime?> lastUpdated = ValueNotifier(null);

EpisodeNotifier episodeProvider = EpisodeNotifier();
PodcastNotifier podcastProvider = PodcastNotifier();

//Stores the current playback state of episodes
Map<String, ValueNotifier<int>> episodeStates = Map();

String? _path;

Future<String?> get path async {
  if (!kIsWeb && _path == null) {
    _path = (await getApplicationDocumentsDirectory()).path;
  }
  return _path;
}

void updateData() async {
  Stopwatch stopwatch = Stopwatch()..start();

  final data = await compute(
      parseAllXml, XmlParamStruct(urls: testData, path: await path));

  podcastProvider.setPodcasts(data.podcasts);
  setEpisodeStates(data.episodeStates);
  episodeProvider.setEpisodes(data.episodes);

  lastUpdated.value = DateTime.now();

  print('Executed in ${stopwatch.elapsed.inSeconds}s');
}

void setEpisodeStates(Map<String, ValueNotifier<int>> states) {
  for (var entry in states.entries) {
    if (episodeStates.containsKey(entry.key)) {
      episodeStates[entry.key]!.value = entry.value.value;
    } else {
      episodeStates.putIfAbsent(entry.key, () => entry.value);
    }
  }
}

class LayoutNotifier extends StateNotifier<bool> {
  LayoutNotifier() : super(true);

  bool get isMobile => state;

  void setWidth(double width) {
    bool newState = width < 500;

    if (newState != state) state = newState;
  }
}

class PodcastNotifier extends StateNotifier<Map<String, Podcast>> {
  PodcastNotifier() : super({});

  Map<String, Podcast> get currentState => state;

  void test() {
    state = state;
  }

  void removePodcast(String uuid) {
    state.remove(uuid);
  }

  void setPodcasts(Map<String, Podcast> podcasts) => state = podcasts;

  Stream<Set<Podcast>> get podcasts async* {
    await for (Map<String, Podcast> item in stream) {
      yield item.values.toSet();
    }
  }
}

class EpisodeNotifier extends StateNotifier<Map<String, Episode>> {
  EpisodeNotifier() : super({});

  Map<String, Episode> get currentState => state;

  void setEpisodes(Map<String, Episode> episodes) => state = episodes;

  void addEpisodes(Map<String, Episode> episodes) {
    Map<String, Episode> newState = state;

    for (var key in episodes.keys) {
      if (newState.containsKey(key))
        newState.update(key, (value) => episodes[key]!);
      else
        newState.putIfAbsent(key, () => episodes[key]!);
    }
    state = newState;
  }

  Stream<Set<Episode>> get episodes async* {
    await for (Map<String, Episode> item in stream) {
      yield item.values.toSet();
    }
  }
}

class Podcast {
  const Podcast({
    required this.title,
    required this.id,
    required this.author,
    required this.img,
    required this.description,
    required this.url,
    required this.link,
    required this.episodes,
    required this.explicit,
  });

  final String title, url, id;
  final String? img, description, link, author;
  final List<String> episodes;
  final bool explicit;

  Stream<Set<Episode>> get episodesStream => podcastProvider.stream
          .startWith(podcastProvider.currentState)
          .combineLatest(
              episodeProvider.stream.startWith(episodeProvider.currentState),
              (Map<String, Podcast> podcasts, Map<String, Episode> episodes) {
        print("a³a");
        final Set<Episode> result = {};

        if (podcasts.containsKey(this.id)) {
          for (String episodeId in podcasts[this.id]!.episodes) {
            if (episodes.containsKey(episodeId)) {
              result.add(episodes[episodeId]!);
            }
          }
        }

        return result;
      });
}

class Episode {
  const Episode({
    required this.title,
    required this.audioUrl,
    required this.description,
    required this.podcastId,
    required this.episodeId,
    required this.date,
    required this.duration,
  });

  final String title, audioUrl, description, podcastId, episodeId;
  final DateTime? date;
  final Duration? duration;

  ValueNotifier<int> get progress {
    if (!episodeStates.containsKey(episodeId))
      episodeStates.putIfAbsent(episodeId, () => ValueNotifier(0));
    return episodeStates[episodeId]!;
  }

  Podcast get podcast {
    return podcastProvider.currentState[podcastId]!;
  }
/*String get dateString {
    String dateString = '<NO DATE>';
    if (date != null) {
      final now = DateTime.now();
      Duration diff = now.difference(date);

      if (diff.inHours < 24)
        dateString = '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
      else if (diff.inDays <= 7)
        dateString = '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
      else
        dateString = dateTimeToDayString(date);
    }
    return dateString;
  }*/
}
/*
Stream<Set<Episode>> createCs(String podcastId, Stream<Map<String, Podcast>> as,
        Stream<Map<String, Episode>> bs) =>
    StreamZip([as, bs]).map((ab) {
      print("aaa");
      Set<Episode> result = {};
      try {
        Map<String, Podcast> podcasts = ab[0] as Map<String, Podcast>;
        Map<String, Episode> episodes = ab[1] as Map<String, Episode>;

        for (String episodeId in podcasts[podcastId]!.episodes) {
          if (episodes.containsKey(episodeId)) result.add(episodes[episodeId]!);
        }
      } catch (e) {
        print(e);
        return result;
      }

      //List<String> episodeIds = ab[0].
      return result;
    });
 */
/*
 Stream<Set<Episode>> get episodesStream =>
      StreamZip([podcastProvider.stream, episodeProvider.stream]).map((ab) {
        print("aaa");
        Set<Episode> result = {};
        try {
          Map<String, Podcast> podcasts = ab[0] as Map<String, Podcast>;
          Map<String, Episode> episodes = ab[1] as Map<String, Episode>;

          for (String episodeId in podcasts[this.id]!.episodes) {
            if (episodes.containsKey(episodeId))
              result.add(episodes[episodeId]!);
          }
        } catch (e) {
          print(e);
          return result;
        }

        //List<String> episodeIds = ab[0].
        return result;
      });
 */