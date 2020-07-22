import 'package:flutter/material.dart';
import 'package:podcast_player/screens/settings_screen.dart';

typedef void OnChange(String value);

class SettingsSection extends StatefulWidget {
  final OnChange onChange;
  final String title, description;
  final List<String> selectable;
  final int index;

  const SettingsSection(
      {Key key,
      this.onChange,
      @required this.title,
      this.description,
      @required this.selectable,this.index = 0})
      : super(key: key);

  @override
  _SettingsSectionState createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection> {
  String dropdownValue;

  @override
  void initState() {
    dropdownValue = widget.selectable[widget.index];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: paddingHorizontal,vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headline6,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4,bottom: 16),
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
                child: DropdownButton<String>(
                  onChanged: (val) {
                    setState(() {
                      dropdownValue = val;
                    });
                    widget.onChange(val);
                  },
                  style: TextStyle(color: Colors.black),
                  value: dropdownValue,
                  items: widget.selectable
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
