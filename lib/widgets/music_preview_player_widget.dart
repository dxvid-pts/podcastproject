import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:podcast_player/widgets/player.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils.dart';

const double opacityRange = 0.15;

class MusicPreviewWidget extends StatelessWidget {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  /*final todo*/ Map<int, String> timestamps;

  MusicPreviewWidget({Key key,@required this.timestamps}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: positionUpdateStream,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (!snapshot.hasData) return Container();
          const testUrl =
              'https://open.spotify.com/embed/track/7C5smrAPC21rQ9gtcRIYs2';

          int startingPoint = 603;
          //for (int i = 0; i < 30; i++)
          timestamps.putIfAbsent(startingPoint, () => testUrl);

          if (timestamps.keys.contains(snapshot.data)) {
            AudioService.pause();
            Future.delayed(Duration(seconds: 29))
                .then((value) => AudioService.play());

            return ValueListenableBuilder(
              valueListenable: playerExpandProgress,
              child: SizedBox(
                height: 83,
                child: WebView(
                  initialMediaPlaybackPolicy:
                      AutoMediaPlaybackPolicy.always_allow,
                  initialUrl:
                      'https://open.spotify.com/embed/track/7C5smrAPC21rQ9gtcRIYs2',
                  javascriptMode: JavascriptMode.unrestricted,
                  onPageFinished: (f) {
                    print('finished $f');
                    _controller.future.then((webViewController) =>
                        webViewController.evaluateJavascript(
                            'var node = document.querySelector(\'[title="Play"]\'); node.click();'));
                  },
                  onWebViewCreated: (WebViewController webViewController) {
                    print('web finisjed');
                    _controller.complete(webViewController);
                  },
                  //gestureNavigationEnabled: true,
                ),
              ),
              builder: (BuildContext context, double height, Widget child) {
                final percentage = percentageFromValueInRange(
                    min: playerMinHeight, max: playerMaxHeight, value: height);

                final finalWidget = Padding(
                  padding: EdgeInsets.only(bottom: height),
                  child: child,
                );

                double opacity = 0;
                if (percentage == 0 || percentage == 1) opacity = 1;

                var opacityPercentage = percentageFromValueInRange(
                    min: 0, max: 0 + opacityRange, value: percentage);
                if (opacityPercentage < 1) opacity = 1 - opacityPercentage;

                opacityPercentage = percentageFromValueInRange(
                    min: 1 - opacityRange, max: 1, value: percentage);
                if (opacityPercentage > 0) opacity = opacityPercentage;

                return Opacity(
                  opacity: opacity,
                  child: finalWidget,
                );
              },
            );
          } else
            return Container();
        });
  }
}
