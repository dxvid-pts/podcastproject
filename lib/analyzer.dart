import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:podcast_player/main.dart';
import 'package:podcast_player/utils.dart';
import 'package:podcast_player/widgets/player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

SharedPreferences prefs;

typedef String ExtractFunction();

Future<void> loadPodcasts({bool skipSharedPreferences = false}) async {
  Set<String> keys;

  if (!skipSharedPreferences) {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    //Load current Episode
    final String currentCachedEpisodeUrl = prefs.getString('current_episode');

    keys = prefs.getKeys()..removeWhere((key) => !key.startsWith('feed:'));

    //podcastCount = keys.length;
    print('load podcasts: ' + keys.length.toString());

    //loadCached
    await Future.wait(keys.map((url) async {
      try {
        Podcast cached = await podcastFromXml(
            url.replaceFirst('feed:', ''), prefs.getString(url));
        print(cached.title);

        //Set current Episode if loaded && != null
        if (currentCachedEpisodeUrl != null)
          cached.episodes.forEach((episodeUrl) {
            if (episodeUrl == currentCachedEpisodeUrl) {
              firstEpisodeLoadedFromSP = true;
              currentlyPlaying.value = episodes[episodeUrl];
            }
          });
      } catch (e) {
        print('error: $e');
      }
    }));
  } else {
    keys = podcasts.keys.toSet();
  }

  //refresh Feeds
  //if (skipSharedPreferences)
  await Future.wait(keys.map((url) async {
    if (url.startsWith('feed:')) url = url.split('feed:')[1];

    try {
      podcastFromXml(url, await fetchXml(url));
    } catch (_) {}
  }));
}

Future<String> fetchXml(final String url, {final bool ignoreCache}) async {
  if (ignoreCache == false && prefs.containsKey("feed:" + url)) {
    return prefs.getString(url);
  } else {
    print('fetch: $url');
    final feed = await compute(fetchXmlOnIsolate, url);
    saveFeedAsync(prefs, url, feed);

    return feed;
  }
}

Future<String> fetchXmlOnIsolate(final String url) async {
  return utf8.decode((await http.get(url)).bodyBytes);
}

Future<Podcast> podcastFromXml(final String url, final String xml) async {
  final List returns =
      await compute(podcastFromXmlOnIsolate, [url, xml]).catchError((onError) {
    print('onError $onError');
  });
  Podcast podcast = returns[0];
  Map<String, Episode> episodesFromIsolate = returns[1];

  //Create ValueNotifiers for every episode
  podcast.episodes.forEach((episodeUrl) {
    if (episodeUrl != null) {
      saveEpisodeState(episodeUrl, prefs.getInt('state:' + episodeUrl) ?? 0,
          save: false);
      setEpisodeDownloadState(episodeUrl, 0, replace: false);
    }
  });

  if (!podcasts.containsKey(url))
    podcasts.putIfAbsent(url, () => podcast);
  else
    podcasts.update(url, (_) => podcast);

  episodes.addAll(episodesFromIsolate);

  updateStream.add(url);

  return podcast;
}

List podcastFromXmlOnIsolate(List<String> args) {
  String url = args[0];
  final String xml = args[1];
  Map<String, Episode> episodesIsolate = Map();

  print('podcastFromXml');

  Podcast podcast = Podcast();
  if (url.startsWith('feed:')) url = url.split('feed:')[1];
  final document = XmlDocument.parse(xml); // xmlDoc.parse(xml);

  final channelElement = document.findAllElements("channel").first;

  //title
  podcast.title = channelElement.findElements("title").first.text;

  //description //TODO: itunes:summary
  podcast.description = getValue([
    () => channelElement.findElements("description").first.text,
    () => channelElement.findElements("itunes:summary").first.text,
  ]);

  //image
  podcast.img = getValue([
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
  podcast.author = getValue([
    () => getDataFromMultipleTags(channelElement, ["author", "copyright"]),
    () => channelElement
        .findElements("itunes:owner")
        .first
        .findElements("itunes:name")
        .first
        .text,
  ]);

  //explicit
  podcast.explicit = getValue(
          [() => channelElement.findElements("itunes:explicit").first.text]) ==
      'yes';

  //link
  podcast.link = getValue([
    () => channelElement.findElements("link").first.text,
  ]);

  podcast.url = url;

  //episodes
  podcast.episodes = document.findAllElements('item').map((e) {
    String title, description, audioUrl;
    DateTime dateTime;
    Duration duration;

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
        month = makeDateString('M', split[2].length);
      }
      if (split[3].length != year.length) {
        year = makeDateString('y', split[3].length);
      }
      /*if (split[4].length != time.length) {
        time = makeDateString('E', split[4].length);
      }*/
      if (split[5].length != zone.length) {
        zone = makeDateString('z', split[5].length);
      }

      //print(data);
      //print("$weekDay $day $month $year $time $zone");
      dateTime =
          DateFormat("$weekDay $day $month $year $time $zone").parse(data);
      //dateTime = DateFormat("EEE, dd MMM yyyy hh:mm:ss zzz").parse(e.findElements('pubDate').first.text);
    } catch (e) {
      print(e);
    }

    //audioUrl
    try {
      audioUrl = getXmlValue(() {
        return e.findElements('enclosure').first.getAttribute('url');
      });

      if (audioUrl != null) audioUrl = audioUrl.replaceAll('http:', 'https:');
      // if (audioUrl != null)
      //  saveEpisodeState(audioUrl, prefs.getInt('state:' + audioUrl) ?? 0,
      //       save: false);
    } catch (e) {
      print(e);
    }

    //title
    try {
      title = e.findElements('title').first.text;
    } catch (e) {
      print(e);
    }

    //description
    try {
      description = e.findElements('description').first.text;
    } catch (e) {
      print(e);
    }

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
    episodesIsolate.putIfAbsent(
        audioUrl,
        () => Episode()
          ..title = title
          ..audioUrl = audioUrl
          ..description = description
          ..date = dateTime
          ..podcastUrl = url
          ..duration = duration);

    return audioUrl;
  }).toList();

  /* if (!podcasts.containsKey(url))
    podcasts.putIfAbsent(url, () => podcast);
  else
    podcasts.update(url, (_) => podcast);

  updateStream.add(url);*/
  return [podcast, episodesIsolate];
}

String getValue(List<ExtractFunction> functions) {
  for (ExtractFunction function in functions) {
    String ram;
    try {
      ram = function();
    } catch (_) {
      continue;
    }
    if (ram == null) continue;
    return ram;
  }
}

String getXmlValue(Function function) {
  try {
    return function();
  } catch (_) {}
  return null;
}

Future<Podcast> podcastFromUrl(final String url) async {
  if (podcasts.containsKey(url)) {
    return podcasts[url];
  }
  return podcastFromXml(url, await fetchXml(url, ignoreCache: true));
}

void saveFeedAsync(
    final SharedPreferences prefs, final String url, final String feed) async {
  prefs.setString("feed:" + url, feed);
}

String getDataFromMultipleTags(
    final XmlElement element, final List<String> tags) {
  for (String tag in tags) {
    var i = element.findElements(tag);
    if (i.isNotEmpty) return i.first.text;
  }
  return null;
}

void saveEpisodeState(final String url, final int state,
    {final bool save = true}) {
  if (!episodeStates.containsKey(url))
    episodeStates.putIfAbsent(url, () => ValueNotifier(state));
  else
    episodeStates[url].value = state;

  /*podcasts.values.forEach((podcast) {
    podcast.episodes
        .where((episode) => episode.audioUrl == url)
        .forEach((episode) {
      episode.state.value = state;
    });
  });*/

  if (save) prefs.setInt('state:' + url, state);
}

void saveCurrentEpisode(final String audioUrl) {
  if (audioUrl == null)
    prefs.remove('current_episode');
  else
    prefs.setString('current_episode', audioUrl);
}

String makeDateString(final String c, final int length) {
  String result = '';
  for (int i = 0; i < length; i++) result = result + c;
  return result;
}

void unsubscribePodcast(String url) {
  if (prefs.containsKey('feed:$url')) prefs.remove('feed:$url');
  podcasts.remove(url);
  updateStream.add('remove:$url');
}

const String splitForm = '#;#';

void addToHistory(String episodeAudioUrl,
    {skipSharedPreferences = false, DateTime datetime}) {
  if (datetime == null) datetime = dayToday();

  if (!skipSharedPreferences) {
    final String key = 'history:$episodeAudioUrl',
        value = datetime.toIso8601String();
    prefs.setString(key, value);

    //Notify history_screen to update
    historyNotifier.value = historyNotifier.value + 1;
  }

  if (history.containsKey(datetime))
    history.update(
      datetime,
      (list) => list..add(episodeAudioUrl),
    );
  else
    history.putIfAbsent(datetime, () => [episodeAudioUrl]);
}

void loadHistory() {
  if (prefs == null) return;

  if (history == null) history = Map();

  final keys = prefs.getKeys()
    ..removeWhere((key) => !key.startsWith('history:'));

  for (String key in keys) {
    final episodeAudioUrl = key.replaceFirst('history:', '');
    //TODO: final
    var date = prefs.getString(key);

    //TODO: remove
    if (date.contains(splitForm)) date = date.split(splitForm)[1];
    //TODO: end result: final DateTime dateTime = DateTime.parse(date);
    final DateTime ram = DateTime.parse(date);
    final DateTime dateTime = DateTime(ram.year, ram.month, ram.day);

    addToHistory(episodeAudioUrl,
        skipSharedPreferences: true, datetime: dateTime);
  }
}

Map<DateTime, List<String>> history;

Map<DateTime, List<String>> getHistory() {
  if (history == null) loadHistory();

  return history;
}

Map<String, List<Episode>> playlists = Map();

bool isEpisodeInPlaylist(final Episode episode, final String playlistName) {
  for (Episode element in getPlaylistContent(playlistName))
    if (element.title == episode.title) return true;
  return false;
}

void removeFromPlaylist(final Episode episode, final String playlistName) {
  if (!playlists.containsKey(playlistName)) {
    return;
  }

  playlists.update(playlistName, (list) => list..remove(episode));

  final String key = 'pl:$playlistName';
  List<String> value = (prefs.getStringList(key) ?? List());
  if (value.contains(episode.audioUrl))
    value.remove(episode
        .audioUrl); //'${episode.audioUrl}$splitForm${datetime.toIso8601String()}'
  prefs.setStringList(key, value);
}

void addToPlaylist(final Episode episode, final String playlistName,
    {bool ignorePrefs = false}) {
  if (playlists.containsKey(playlistName))
    playlists.update(playlistName, (listValue) => listValue..add(episode));
  else
    playlists.putIfAbsent(playlistName, () => [episode]);

  if (!ignorePrefs) {
    //final datetime = DateTime.now();
    final String key = 'pl:$playlistName';

    List<String> value = (prefs.getStringList(key) ?? List())
      ..add(episode
          .audioUrl); //'${episode.audioUrl}$splitForm${datetime.toIso8601String()}'
    prefs.setStringList(key, value);
  }
}

Set<String> listPlaylists() {
  if (playlists.isNotEmpty) return playlists.keys.toSet();

  Set<String> playlistNames = Set();

  prefs.getKeys().forEach((key) {
    if (key.startsWith('pl:')) playlistNames.add(key.replaceFirst('pl:', ''));
  });

  return playlistNames;
}

void loadPlaylistsFromPrefs() {
  prefs.getKeys().forEach((prefKey) {
    if (prefKey.startsWith('pl:')) {
      final String playlistName = prefKey.replaceFirst('pl:', '');
      final List<String> episodeUrlList =
          prefs.getStringList(prefKey) ?? List();

      for (String audioUrl in episodeUrlList) {
        addToPlaylist(episodes[audioUrl], playlistName, ignorePrefs: true);
      }
    }
  });
}

List<Episode> getPlaylistContent(final String playlistName) {
  if (playlists.isEmpty) loadPlaylistsFromPrefs();

  if (!playlists.containsKey(playlistName)) return List();
  return playlists[playlistName];
}

void loadDownloadedFiles() async {
  await FlutterDownloader.initialize(
    debug: true, // optional: set false to disable printing logs to console
  );
  final tasks = await FlutterDownloader.loadTasksWithRawQuery(
      query: "SELECT * FROM task WHERE status=3");
  for (DownloadTask task in tasks) {
    episodeDownloadInfo.putIfAbsent(task.url, () => task);
    setEpisodeDownloadState(task.url, task.progress);
  }

  FlutterDownloader.registerCallback(downloadCallback);
}

void downloadCallback(String id, DownloadTaskStatus status, int progress) {
  final SendPort send = IsolateNameServer.lookupPortByName(id);
  send.send([id, status, progress]);
}

void subscribeToDownload(final String taskId) {
  ReceivePort _port = ReceivePort();
  IsolateNameServer.registerPortWithName(_port.sendPort, taskId);
  _port.listen((dynamic data) {
    String id = data[0];
    DownloadTaskStatus status = data[1];
    int progress = data[2];

    print('id: $id, progress $progress status $status');

    //prevent errors
    if (!episodeDownloadTasks.containsKey(id)) {
      print('!contains id: $id');
      print(episodeDownloadTasks.toString());
      return;
    }

    String audioUrl = episodeDownloadTasks[id];
    setEpisodeDownloadState(audioUrl, progress);

    //remove taskId from Map when finished
    if (status == DownloadTaskStatus.complete) {
      episodeDownloadTasks.remove(id);
      IsolateNameServer.removePortNameMapping(taskId);
    }
  });
}

void setEpisodeDownloadState(final String audioUrl, final int progress,
    {final bool replace = true}) {
  if (!episodeDownloadStates.containsKey(audioUrl))
    episodeDownloadStates.putIfAbsent(audioUrl, () => ValueNotifier(progress));
  else if (replace) episodeDownloadStates[audioUrl].value = progress;
}

void saveSetting(final String key, final int value) =>
    prefs.setInt('sett:$key', value);

int getSetting(final String key) => prefs.getInt('sett:$key');
