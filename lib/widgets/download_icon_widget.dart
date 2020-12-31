import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

import '../analyzer.dart';
import '../main.dart';

class DownloadIconButton extends StatefulWidget {
  final String episodeAudioUrl;

  const DownloadIconButton({Key key, @required this.episodeAudioUrl})
      : super(key: key);

  @override
  _DownloadIconButtonState createState() => _DownloadIconButtonState();
}

class _DownloadIconButtonState extends State<DownloadIconButton> {
  String _taskId;

  @override
  void initState() {
    super.initState();

    if (episodeDownloadInfo[widget.episodeAudioUrl] != null)
      _taskId = episodeDownloadInfo[widget.episodeAudioUrl].taskId;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      builder: (_, int _progress, __) {
        if (_progress == 100)
          return PopupMenuButton(
            tooltip: 'Remove download',
            onSelected: deleteDownload,
            icon: DownloadIcon(
              progress: _progress,
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                value: true,
                child: Text('Remove download'),
              ),
            ],
          );
        return IconButton(
          tooltip: 'Download',
          icon: DownloadIcon(
            progress: _progress,
          ),
          onPressed: () {
            if (_progress != 100) download();
            //else
            // pausePlayDownload();
          },
        );
      },
      valueListenable: episodeDownloadStates[widget.episodeAudioUrl],
    );
  }

  void download() async {
    var taskId = await FlutterDownloader.enqueue(
      url: widget.episodeAudioUrl,
      savedDir: (await getApplicationSupportDirectory()).path,
      showNotification: true,
      // show download progress in status bar (for Android)
      openFileFromNotification:
          false, // click on notification to open downloaded file (for Android)
    );
    subscribeToDownload(taskId);
    episodeDownloadTasks.putIfAbsent(taskId, () => widget.episodeAudioUrl);
    print('episodeDownloadTasks: ${episodeDownloadTasks.toString()}');
  }

  void deleteDownload(dynamic _) {
    FlutterDownloader.remove(taskId: _taskId, shouldDeleteContent: false);
    episodeDownloadInfo.remove(widget.episodeAudioUrl);
    episodeDownloadStates[widget.episodeAudioUrl].value = 0;
    downloadNotifier.value = downloadNotifier.value - 1;
  }

  void pausePlayDownload() {}
}

class DownloadIcon extends StatelessWidget {
  final progress;
  final double iconSize;

  const DownloadIcon({Key key, @required this.progress, this.iconSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return progress == 100
        ? Icon(
            Icons.offline_pin,
            size: iconSize,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.green
                : Colors.greenAccent,
          )
        : progress != 0
            ? SizedBox(
                height: iconSize == null ? null : iconSize * 2 / 3,
                width: iconSize == null ? null : iconSize * 2 / 3,
                child: CircularProgressIndicator(
                  strokeWidth: iconSize != null ? 2 : 4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  value: progress / 100,
                ),
              )
            : Icon(Icons.file_download);
  }
}
