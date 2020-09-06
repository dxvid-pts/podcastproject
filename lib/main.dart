import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podcast_player/screens/main_screen.dart';
import 'package:podcast_player/screens/library_screen/library_screen.dart';
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

StreamController<String> updateStream = StreamController<String>.broadcast();

//used to display skeletons in main_screen.dart
int podcastCount;

bool firstEpisodeLoadedFromSP = false;

final List<GlobalKey<NavigatorState>> _navigatorKeys = [
  GlobalKey(),
  GlobalKey()
];

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
      home: App(),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final NavigatorState navigator =
            _navigatorKeys[_selectedIndex].currentState;
        if (!navigator.canPop()) return true;
        navigator.pop();

        return false;
      },
      child: Scaffold(
        body: AudioServiceWidget(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(/*bottom: miniplayerHeight*/),
                child: IndexedStack(
                  index: _selectedIndex,
                  children: <Widget>[
                    NavigatorPage(
                      navigatorKey: _navigatorKeys[0],
                      child: MainScreen(controller: mainScreenController),
                    ),
                    NavigatorPage(
                      navigatorKey: _navigatorKeys[1],
                      child: LibraryScreen(),
                    ),
                  ],
                ),
              ),
              AudioControllerWidget(),
              ValueListenableBuilder(
                builder: (BuildContext context, Episode episode, Widget child) {
                  if (episode != null &&
                      episode.timestamps != null &&
                      episode.timestamps.keys.length > 0)
                    return MusicPreviewWidget(timestamps: episode.timestamps);
                  return Container();
                },
                valueListenable: currentlyPlaying,
              ),
            ],
          ),
        ),
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable: playerExpandProgress,
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Feed',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books_outlined),
                label: "Library",
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue,
            onTap: (index) {
              if (index == _selectedIndex) {
                final NavigatorState navigator =
                    _navigatorKeys[index].currentState;
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
            },
          ),
          builder: (BuildContext context, double height, Widget child) {
            final value = percentageFromValueInRange(
                min: playerMinHeight, max: playerMaxHeight, value: height);

            if (value == null) return child;
            var opacity = 1 - value;
            if (opacity < 0) opacity = 0;
            if (opacity > 1) opacity = 1;

            return SizedBox(
              height: kBottomNavigationBarHeight -
                  kBottomNavigationBarHeight * value,
              child: Transform.translate(
                offset: Offset(0.0, kBottomNavigationBarHeight * value * 0.5),
                child: Opacity(
                  opacity: opacity,
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
