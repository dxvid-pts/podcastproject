import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podcast_player/podcast_icons_icons.dart';
import 'package:podcast_player/screens/main_screen.dart';
import 'package:podcast_player/screens/library_screen/library_screen.dart';
import 'package:podcast_player/screens/settings_screen/settings_screen.dart';
import 'package:podcast_player/utils.dart';
import 'package:podcast_player/widgets/music_preview_player_widget.dart';
import 'package:podcast_player/widgets/navigator_page_widget.dart';
import 'package:podcast_player/widgets/player.dart';

import 'analyzer.dart';

Map<String, Podcast> podcasts = Map();
Map<String, Episode> episodes = Map();

//Stores the current playback state of episodes
Map<String, ValueNotifier<int>> episodeStates = Map();

//Used to store information about downloaded episodes such as file path, etc
Map<String, DownloadTask> episodeDownloadInfo = Map();

//audioUrl, progress
Map<String, ValueNotifier<int>> episodeDownloadStates = Map();

//taskId, audioUrl
Map<String, String> episodeDownloadTasks = Map();

//Used to refresh downloaded_episodes_screen.dart whenever a downloaded episode gets deleted.
//Introducing a new value as ValueNotifier doesn't notify about changes in lists (https://github.com/flutter/flutter/issues/29958)
//and not to depend on third party libraries such as "property_change_notifier"
ValueNotifier<int> downloadNotifier = ValueNotifier(0);
ValueNotifier<int> historyNotifier = ValueNotifier(0);

ValueNotifier<DateTime> offlineDate = ValueNotifier(null);

StreamController<String> updateStream = StreamController<String>.broadcast();

//used to display skeletons in main_screen.dart
int podcastCount;

bool firstEpisodeLoadedFromSP = false;

ValueNotifier<bool> isMobile = ValueNotifier(true);
const double mobileWidth = 500;

void main() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  runApp(MyApp());

  WidgetsFlutterBinding.ensureInitialized();

  loadPodcasts();
  if (!kIsWeb) loadDownloadedFiles();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Podcast',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        bottomNavigationBarTheme: BottomNavigationBarTheme.of(context).copyWith(
          selectedLabelStyle: GoogleFonts.lexendDeca(),
          unselectedLabelStyle: GoogleFonts.lexendDeca(),
        ),
      ),
      home: AudioServiceWidget(child: App()),
    );
  }
}

class App extends StatefulWidget {
  App({Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  int _selectedIndex = 0;
  final ScrollController mainScreenController = ScrollController();
  bool _isMobile = true;

  List<NavigationItem> navigationIconsMobile;
  List<NavigationItem> navigationIconsWeb;

  @override
  void initState() {
    navigationIconsMobile = [
      NavigationItem(const Icon(Icons.home_outlined), 'Feed',
          MainScreen(controller: mainScreenController)),
      NavigationItem(
          const Icon(Icons.library_books_outlined), 'Library', LibraryScreen()),
    ];
    navigationIconsWeb = [
      ...navigationIconsMobile,
      NavigationItem(Icon(PodcastIcons.vector), 'Settings', SettingsScreen()),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final body = IndexedStack(
      index: _selectedIndex,
      children: navigationIcons
          .map((item) => NavigatorPage(
                navigatorKey: item.key,
                child: item.child,
              ))
          .toList(),
    );

    return WillPopScope(
      onWillPop: () async {
        final NavigatorState navigator =
            navigationIcons[_selectedIndex].key.currentState;
        if (!navigator.canPop()) return true;
        navigator.pop();

        return false;
      },
      child: LayoutBuilder(
        builder: (context, constrains) {
          print(constrains.maxWidth);
          _isMobile = constrains.maxWidth <= mobileWidth;
          if (_isMobile != isMobile.value) isMobile.value = _isMobile;

          return Scaffold(
            body: _isMobile
                ? Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      body,
                      AudioControllerWidget(),
                      if (!kIsWeb)
                        ValueListenableBuilder(
                          builder: (BuildContext context, Episode episode,
                              Widget child) {
                            if (episode != null &&
                                episode.timestamps != null &&
                                episode.timestamps.keys.length > 0)
                              return MusicPreviewWidget(
                                  timestamps: episode.timestamps);
                            return Container();
                          },
                          valueListenable: currentlyPlaying,
                        ),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            NavigationRail(
                              selectedIndex: _selectedIndex,
                              onDestinationSelected: onNavigationTap,
                              labelType: NavigationRailLabelType.all,
                              destinations: navigationIcons
                                  .map(
                                    (item) => NavigationRailDestination(
                                      icon: item.icon,
                                      label: Text(item.label),
                                    ),
                                  )
                                  .toList(),
                            ),
                            VerticalDivider(thickness: 1, width: 1),
                            // This is the main content.
                            Expanded(child: body),
                          ],
                        ),
                      ),
                      AudioControllerWidget(isMobile: false),
                    ],
                  ),
            bottomNavigationBar: !_isMobile
                ? null
                : ValueListenableBuilder(
                    valueListenable: playerExpandProgress,
                    child: BottomNavigationBar(
                      items: navigationIcons
                          .map(
                            (item) => BottomNavigationBarItem(
                              icon: item.icon,
                              label: item.label,
                            ),
                          )
                          .toList(),
                      currentIndex: _selectedIndex,
                      selectedItemColor: Colors.blue,
                      onTap: onNavigationTap,
                    ),
                    builder:
                        (BuildContext context, double height, Widget child) {
                      final value = percentageFromValueInRange(
                          min: playerMinHeight,
                          max: playerMaxHeight,
                          value: height);

                      if (value == null) return child;
                      var opacity = 1 - value;
                      if (opacity < 0) opacity = 0;
                      if (opacity > 1) opacity = 1;

                      return SizedBox(
                        height: kBottomNavigationBarHeight -
                            kBottomNavigationBarHeight * value,
                        child: Transform.translate(
                          offset: Offset(
                              0.0, kBottomNavigationBarHeight * value * 0.5),
                          child: Opacity(
                            opacity: opacity,
                            child: child,
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  void onNavigationTap(final int index) {
    if (index == _selectedIndex) {
      final NavigatorState navigator = navigationIcons[index].key.currentState;
      if (navigator.canPop())
        while (navigator.canPop()) navigator.pop();
      else {
        if (index == 0)
          mainScreenController.animateTo(
            0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
      }
    } else
      setState(() {
        _selectedIndex = index;
      });
  }

  List<NavigationItem> get navigationIcons {
    if (!_isMobile) return navigationIconsWeb;
    return navigationIconsMobile;
  }
}

class NavigationItem {
  final String label;
  final Icon icon;
  final key = GlobalKey();
  final Widget child;

  NavigationItem(this.icon, this.label, this.child);
}
