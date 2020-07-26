import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

import '../main.dart';

class DownloadIconButton extends StatefulWidget {
  final String episodeAudioUrl;
  final bool showGreaterZeroOnly;
  final double iconSize;

  const DownloadIconButton(
      {Key key,
      @required this.episodeAudioUrl,
      this.showGreaterZeroOnly = false,
      this.iconSize})
      : super(key: key);

  @override
  _DownloadIconButtonState createState() => _DownloadIconButtonState();
}

class _DownloadIconButtonState extends State<DownloadIconButton> {
  ReceivePort _port = ReceivePort();
  int _progress = 0;
  String _taskId;
  StreamSubscription _streamListener;

  @override
  void initState() {
    super.initState();
    if (episodeDownloadStates[widget.episodeAudioUrl] != null)
      _progress = episodeDownloadStates[widget.episodeAudioUrl];

    if (episodeDownloadInfo[widget.episodeAudioUrl] != null)
      _taskId = episodeDownloadInfo[widget.episodeAudioUrl].taskId;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showGreaterZeroOnly)
      return DownloadIcon(
        progress: _progress,
        showGreaterZeroOnly: true,
        iconSize: widget.iconSize,
      );
    return IconButton(
      tooltip: 'Download',
      icon: DownloadIcon(
        progress: _progress,
        showGreaterZeroOnly: false,
      ),
      onPressed: () {
        if (_progress != 100)
          download();
        else if (_progress == 100)
          deleteDownload();
        else
          pausePlayDownload();
      },
    );
  }

  @override
  void dispose() {
    if (_streamListener != null) _streamListener.cancel();
    IsolateNameServer.removePortNameMapping(_taskId);
    super.dispose();
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
    setState(() {
      _taskId = taskId;
    });
    IsolateNameServer.registerPortWithName(_port.sendPort, taskId);

    _streamListener = _port.listen((dynamic data) async {
      final DownloadTaskStatus status = data[1];
      final int progress = data[2];

      setState(() {
        _progress = progress;
      });

      if (!episodeDownloadStates.containsKey(widget.episodeAudioUrl))
        episodeDownloadStates.putIfAbsent(
            widget.episodeAudioUrl, () => progress);
      else
        episodeDownloadStates.update(
            widget.episodeAudioUrl, (value) => progress);

      if (status == DownloadTaskStatus.complete) {
        IsolateNameServer.removePortNameMapping(_taskId);

        //Save file data on Comlete -> audio player has files
        final task = (await FlutterDownloader.loadTasksWithRawQuery(
                query: 'SELECT * FROM task WHERE status=3'))
            .where((downloadTask) => downloadTask.taskId == taskId)
            .first;

        if (!episodeDownloadInfo.containsKey(widget.episodeAudioUrl))
          episodeDownloadInfo.putIfAbsent(widget.episodeAudioUrl, () => task);
        else
          episodeDownloadInfo.update(widget.episodeAudioUrl, (value) => task);
      }
    });
  }

  void deleteDownload() {
    FlutterDownloader.remove(taskId: _taskId, shouldDeleteContent: false);
    episodeDownloadStates.remove(widget.episodeAudioUrl);
    episodeDownloadInfo.remove(widget.episodeAudioUrl);
    setState(() {
      _progress = 0;
    });
  }

  void pausePlayDownload() {}
}

class DownloadIcon extends StatelessWidget {
  final progress;
  final bool showGreaterZeroOnly;
  final double iconSize;

  const DownloadIcon(
      {Key key,
      @required this.progress,
      @required this.showGreaterZeroOnly,
      this.iconSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return progress == 100
        ? Icon(
            Icons.offline_pin,
            size: iconSize,
            color: Colors.green,
          )
        : progress != 0
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                value: progress / 100,
              )
            : showGreaterZeroOnly ? Container() : Icon(Icons.file_download);
  }
}
