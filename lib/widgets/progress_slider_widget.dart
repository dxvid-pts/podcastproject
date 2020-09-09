import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

int savedProgress = 0;

class AudioProgressSlider extends StatefulWidget {
  final Stream<int> progressStream;
  final Stream<int> durationStream;
  final bool miniplayer;

  const AudioProgressSlider(
      {Key key,
      @required this.progressStream,
      @required this.durationStream,
      this.miniplayer = false})
      : super(key: key);

  @override
  _AudioProgressSliderState createState() => _AudioProgressSliderState();
}

class _AudioProgressSliderState extends State<AudioProgressSlider> {
  double _sliderValue = 0;
  bool _sliding = false;
  int _duration = 1;
  int _progress = savedProgress;
  bool _loading = true;

  StreamSubscription _durationStreamSubscription;
  StreamSubscription _progressStreamSubscription;

  @override
  void initState() {
    _durationStreamSubscription = widget.durationStream.listen((duration) {
      if (duration == null) {
        setState(() {
          _loading = true;
        });
        return;
      }

      if (duration == _duration) return;
      setState(() {
        _duration = duration;
        if (!_sliding)
          _sliderValue = _progress > duration ? 1.0 : _progress / duration;
        _loading = false;
      });
    });
    _progressStreamSubscription = widget.progressStream.listen((progress) {
      if (_sliding) return;

      setState(() {
        _progress = progress;
        _sliderValue = progress > _duration ? 1.0 : progress / _duration;
      });
      savedProgress = progress;
    });

    super.initState();
  }

  @override
  void dispose() {
    _durationStreamSubscription.cancel();
    _progressStreamSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.miniplayer && !_loading) {
      

      return Column(
        children: [
          Slider(
            value: _sliderValue,
            activeColor: Colors.blueGrey,
            onChangeStart: (_) {
              setState(() {
                _sliding = true;
              });
            },
            onChanged: (double value) {
              setState(() {
                _sliderValue = value;
                _progress = (_duration * value).floor();
              });
            },
            onChangeEnd: (value) async {
              await AudioService.seekTo(
                  Duration(seconds: (value * _duration).round()));

              setState(() {
                _sliderValue = value;
                _sliding = false;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(progressString(_progress)),
              Text('-${durationLeftString(_duration, _progress)}'),
            ],
          ),
        ],
      );
    } else
      return LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
          value: _loading ? null : _sliderValue);
  }
}
