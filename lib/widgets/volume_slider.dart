import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:podcast_player/widgets/player.dart';

class VolumeSlider extends StatefulWidget {
  @override
  _VolumeSliderState createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  double value = 1;
  double audioValue = 1;
  double saved;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
            icon: Icon(value == 0
                ? Icons.volume_off_outlined
                : value > 0.5
                    ? Icons.volume_up_outlined
                    : Icons.volume_down_outlined),
            onPressed: () {
              if (audioValue > 0)
                AudioService.customAction('volume', 0);
              else
                AudioService.customAction('volume', audioValue);

              setState(() {
                if (audioValue > 0) {
                  saved = value;
                  value = 0;
                } else
                  value = saved;
              });
            }),
        Padding(
          padding: const EdgeInsets.only(right: 30, left: 10),
          child: SizedBox(
            width: 130,
            child: SliderTheme(
              data: SliderThemeData(
                trackShape: CustomTrackShape(),
              ),
              child: Slider(
                value: value,
                onChanged: (newVal) {
                  final rounded = double.parse(newVal.toStringAsFixed(2));
                  var dist = audioValue - rounded;
                  if (dist < 0) dist = dist * -1;

                  var _audioValue;

                  if (newVal == 1 || newVal == 0)
                    _audioValue = newVal;
                  else if (dist >= 0.1) _audioValue = rounded;

                  setState(() {
                    value = newVal;

                    if (_audioValue != null) audioValue = _audioValue;
                  });
                  if (_audioValue != null) {
                    print(audioValue);
                    AudioService.customAction('volume', _audioValue);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
