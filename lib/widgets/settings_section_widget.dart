import 'package:flutter/material.dart';
import 'package:podcast_player/screens/settings_screen.dart';

import '../analyzer.dart';

class SettingsSection extends StatefulWidget {
  final String title, description, keySettings;
  final List<String> selectable;
  final int initialIndex;

  const SettingsSection(
      {Key key,
      @required this.title,
      this.description,
      @required this.selectable,
      @required this.keySettings,
      this.initialIndex = 0})
      : super(key: key);

  @override
  _SettingsSectionState createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection> {
  int dropdownIndex;

  @override
  void initState() {
    dropdownIndex = getSetting(widget.keySettings) ?? widget.initialIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: paddingHorizontal, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headline6,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: Text(
              widget.description,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Container(
            color: greyAccent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  onChanged: (newIndex) {
                    setState(() {
                      dropdownIndex = newIndex;
                    });
                    saveSetting(widget.keySettings, newIndex);
                  },
                  style: TextStyle(color: Colors.black),
                  value: dropdownIndex,
                  items: <DropdownMenuItem<int>>[
                    for (int i = 0; i < widget.selectable.length; i++)
                      DropdownMenuItem<int>(
                        value: i,
                        child: Text(widget.selectable[i]),
                      )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
/*
widget.selectable
                      .map<DropdownMenuItem<int>>((String value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
 */
