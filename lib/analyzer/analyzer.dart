import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:podcast_player/analyzer/utils.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

typedef String? ExtractFunction();

class XmlSingleDataStruct {
  const XmlSingleDataStruct({
    this.podcastId,
    this.podcast,
    this.episodeStates = const <String, ValueNotifier<int>>{},
    this.episodes = const <String, Episode>{},
  });

  final String? podcastId;
  final Podcast? podcast;
  final Map<String, Episode> episodes;
  final Map<String, ValueNotifier<int>> episodeStates;
}

class XmlReturnStruct {
  const XmlReturnStruct({
    required this.podcasts,
    required this.episodeStates,
    required this.episodes,
  });

  final Map<String, Podcast> podcasts;
  final Map<String, Episode> episodes;
  final Map<String, ValueNotifier<int>> episodeStates;
}

class XmlParamStruct {
  const XmlParamStruct({required this.urls, required this.path});

  final Set<String> urls;
  final String path;
}

const Set<String> testData = {
  "https://anchor.fm/s/6d75e64/podcast/rss",
  "https://funkdisziplin.podigee.io/feed/mp3",
  "https://feeds.captivate.fm/sascha-starck/",
  "https://travel-echo.libsyn.com/rss",
  "https://anchor.fm/s/a626024/podcast/rss",
  "https://dance-charts.podigee.io/feed/mp3",
  "https://feed.podbean.com/rtdeutsch/feed.xml",
  "https://anchor.fm/s/c9dd134/podcast/rss",
  "https://beste-freundinnen.podigee.io/feed/mp3",
  "https://feeds.soundcloud.com/users/soundcloud:users:645411816/sounds.rss",
  "https://anchor.fm/s/31799ed4/podcast/rss",
  "https://wirwarendetektive.podigee.io/feed/aac",
  "https://gunnarkaiser.libsyn.com/rss",
};

/*
Future<Set<Podcast>> loadAllFromDb() async {
  return (await Future.wait<Podcast>(testData.map((url) => parseXml(url))))
      .toSet();
}*/

Future<XmlReturnStruct> parseAllXml(XmlParamStruct data) async {
  final Map<String, Podcast> podcasts = {};
  final Map<String, Episode> episodes = {};
  final Map<String, ValueNotifier<int>> episodeStates = {};

  Set<XmlSingleDataStruct> structs = (await Future.wait<XmlSingleDataStruct>(
          data.urls.map((url) => parseXml(url, data.path))))
      .toSet();

  for (var struct in structs) {
    //skip if something went wrong while parsing podcast
    if (struct.podcastId == null) continue;
    if (struct.podcast == null) continue;

    podcasts.putIfAbsent(struct.podcastId!, () => struct.podcast!);
    episodes.addAll(struct.episodes);
    episodeStates.addAll(struct.episodeStates);
  }

  return XmlReturnStruct(
      podcasts: podcasts, episodeStates: episodeStates, episodes: episodes);
}

Future<XmlSingleDataStruct> parseXml(String url, String path) async {
  print('podcastFromXml');

  if (url.startsWith('feed:')) url = url.split('feed:')[1];

  final uri = Uri.tryParse(url);
  if (uri == null) return XmlSingleDataStruct();

  XmlDocument document;

  try {
    document = XmlDocument.parse((await http.get(uri)).body);
  } catch (_) {
    return XmlSingleDataStruct();
  }

  final String podcastId = Uuid().v1();
  Map<String, Episode> episodes = {};

  final channelElement = document.findAllElements("channel").first;

  //title
  String title = channelElement.findElements("title").first.text;

  //description //TODO: itunes:summary
  String? description = getValue(
    [
      () => channelElement.findElements("description").first.text,
      () => channelElement.findElements("itunes:summary").first.text,
    ],
  );

  //image
  String? img = getValue([
    () => channelElement
        .findElements("image")
        .first
        .findElements("url")
        .first
        .text,
    () =>
        channelElement.findElements('itunes:image').first.getAttribute('href'),
  ]);

  //author
  String? author = getValue([
    () => channelElement.findElements("author").first.text,
    () => channelElement.findElements("copyright").first.text,
    () => channelElement
        .findElements("itunes:owner")
        .first
        .findElements("itunes:name")
        .first
        .text,
  ]);

  //explicit
  bool explicit = getValue(
          [() => channelElement.findElements("itunes:explicit").first.text]) ==
      'yes';

  //link
  String? link = getValue([
    () => channelElement.findElements("link").first.text,
  ]);

  //parse episodes
  for (XmlElement e in document.findAllElements('item')) {
    String title, description, audioUrl;
    DateTime? dateTime;
    Duration? duration;
    final String episodeId = Uuid().v1();

    //dateTime
    try {
      final data = e.findElements('pubDate').first.text;
      final split = data.split(' ');
      String weekDay = 'EEE,',
          day = 'dd',
          month = 'MMM',
          year = 'yyyy',
          time = 'hh:mm:ss',
          zone = 'zzz';

      if (split[0].length != weekDay.length) {
        weekDay = makeDateString('E', split[0].length - 1) + ',';
      }
      if (split[1].length != day.length) {
        day = makeDateString('d', split[1].length);
      }
      if (split[2].length != month.length) {
        split[2] = split[2].substring(0, 3);
      }
      if (split[3].length != year.length) {
        year = makeDateString('y', split[3].length);
      }
      if (split[5].length != zone.length) {
        zone = makeDateString('z', split[5].length);
      }

      dateTime = DateFormat("$weekDay $day $month $year $time $zone").parse(
          "${split[0]} ${split[1]} ${split[2]} ${split[3]} ${split[4]} ${split[5]}");
    } catch (e) {
      print(e);
    }

    //audioUrl
    String? _audioUrl =
        getValue([() => e.findElements('enclosure').first.getAttribute('url')]);
    if (_audioUrl == null) continue;
    audioUrl = _audioUrl.replaceAll('http:', 'https:');

    //title
    title = getValue(
      [() => e.findElements('title').first.text],
      defaultValue: "<NO TITLE>",
    )!;

    //description
    description = getValue(
      [() => e.findElements('description').first.text],
      defaultValue: "<NO TITLE>",
    )!;

    //duration
    try {
      final durationText = e.findElements('itunes:duration').first.text;
      if (durationText.contains(':')) {
        final split = durationText.split(':');

        if (split.length == 2) {
          duration = Duration(
            seconds: int.parse(split[1]),
            minutes: int.parse(split[0]),
            // hours: split.length > 2 ? int.parse(split[2]) : 0,
          );
        } else if (split.length == 3) {
          duration = Duration(
            seconds: int.parse(split[2]),
            minutes: int.parse(split[1]),
            hours: int.parse(split[0]),
            // hours: split.length > 2 ? int.parse(split[2]) : 0,
          );
        }
      } else
        duration = Duration(seconds: int.parse(durationText));
    } catch (e) {
      print(e);
    }

    //save Episode
    episodes.putIfAbsent(
        episodeId,
        () => Episode(
              title: title,
              audioUrl: audioUrl,
              description: description,
              podcastId: podcastId,
              date: dateTime,
              duration: duration,
              episodeId: episodeId,
            ));
  }

  Podcast podcast = Podcast(
      title: title,
      author: author,
      id: podcastId,
      img: img,
      description: description,
      url: url,
      link: link,
      episodes: episodes.keys.toList(),
      explicit: explicit);

  return XmlSingleDataStruct(
    podcastId: podcastId,
    podcast: podcast,
    episodes: episodes,
    episodeStates: await getEpisodeStatesInIsolate(path),
  );
}

String? getValue(List<ExtractFunction> functions, {String? defaultValue}) {
  for (ExtractFunction function in functions) {
    String? candidate;
    try {
      candidate = function();
    } catch (_) {
      continue;
    }
    if (candidate != null) return candidate;
  }
  return defaultValue;
}

String makeDateString(final String c, final int length) {
  String result = '';
  for (int i = 0; i < length; i++) result = result + c;
  return result;
}

Future<Map<String, ValueNotifier<int>>> getEpisodeStatesInIsolate(
    String path) async {
  Map<String, ValueNotifier<int>> _episodeStates = Map();

  Hive.init(path);
  var box = Hive.box<int>('episode_states');

  for (String key in box.keys) {
    try {
      _episodeStates.putIfAbsent(
          key, () => ValueNotifier(box.get(key, defaultValue: 0)!));
    } catch (e) {
      continue;
    }
  }

  return _episodeStates;
}
