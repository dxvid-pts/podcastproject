import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class Podcast {
  String title, author, img, description, url, language, link;
  List<String> episodes;
  List<String> categories;
  bool explicit;
}

class Episode {
  String title, audioUrl, description, podcastUrl;
  DateTime date;
  Duration duration;
}

Future<Podcast> podcastAsFuture(final Podcast podcast) async {
  return podcast;
}

String intToMonth(final int m) {
  switch (m) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';
    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'May';
    case 6:
      return 'Jun';
    case 7:
      return 'Jul';
    case 8:
      return 'Aug';
    case 9:
      return 'Sep';
    case 10:
      return 'Oct';
    case 11:
      return 'Nov';
    case 12:
      return 'Dec';
    default:
      return '';
  }
}

void openLinkInBrowser(BuildContext context, final String url) async {
  try {
    await launch(
      url,
      option: CustomTabsOption(
        toolbarColor: Theme.of(context).primaryColor,
        enableDefaultShare: true,
        enableUrlBarHiding: true,
        showPageTitle: true,
        animation: CustomTabsAnimation.slideIn(),
        extraCustomTabs: <String>[
          // ref. https://play.google.com/store/apps/details?id=org.mozilla.firefox
          'org.mozilla.firefox',
          // ref. https://play.google.com/store/apps/details?id=com.microsoft.emmx
          'com.microsoft.emmx',
        ],
      ),
    );
  } catch (e) {
// An exception is thrown if browser app is not installed on Android device.
    debugPrint(e.toString());
  }
}

class History {
  final String podcastUrl, episodeAudioUrl;
  final DateTime dateTime;

  History(this.podcastUrl, this.episodeAudioUrl, this.dateTime);
}

class DlState{
  final String taskId;
  final int progress;

  DlState(this.taskId, this.progress);
}