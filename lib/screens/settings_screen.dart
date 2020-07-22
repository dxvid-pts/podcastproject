import 'package:flutter/material.dart';
import 'package:podcast_player/widgets/setings_section_widget.dart';

const Color greyAccent = const Color(0x09000000);
const double paddingHorizontal = 26;

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: paddingHorizontal, right: paddingHorizontal, top: 20),
            child: Text(
              'Settings',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(fontSize: 22, fontWeight: FontWeight.normal),
            ),
          ),
          SettingsSection(
            title: 'Audio behaviour',
            description: "If another app is claiming the audio focus...",
            selectable: [
              'Ignore and continue playing',
              'Lower volume and continue playing',
              'Stop audio'
            ],
            index: 2,
            onChange: (value) {
              //TODO:
            },
          ),
          SettingsSection(
            title: 'Audio behaviour',
            description: "If another app is claiming the audio focus...",
            selectable: [
              'Ignore and continue playing',
              'Lower volume and continue playing',
              'Stop audio'
            ],
            index: 2,
            onChange: (value) {
              //TODO:
            },
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: paddingHorizontal),
            child: FlatButton.icon(
              color: greyAccent,
              icon: Icon(
                Icons.assignment,
                color: Colors.black.withOpacity(0.6),
              ),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 19),
                child: Text('Licenses'),
              ),
              onPressed: () => showLicensePage(
                context: context,
                applicationName: "Podcast-Player",
                applicationVersion: "1.1.0",
                //applicationIcon: "applicationIcon",
                applicationLegalese:
                    "Developed by David Peters\nhttps://www.peterscode.co",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
