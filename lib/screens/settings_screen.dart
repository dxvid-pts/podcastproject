import 'package:flutter/material.dart';
import 'package:podcast_player/widgets/settings_section_widget.dart';

const Color greyAccent = const Color(0x09000000);
const double paddingHorizontal = 26;

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(
        //color: Colors.green,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: paddingHorizontal,
                      right: paddingHorizontal,
                      top: 20),
                  child: Text(
                    'Settings',
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(fontSize: 22, fontWeight: FontWeight.normal),
                  ),
                ),
                SettingsSection(
                  keySettings: 'audio_behaviour',
                  title: 'Audio behaviour',
                  description: "If another app is claiming the audio focus...",
                  selectable: [
                    /*0*/ 'Ignore and continue playing',
                    /*1*/ 'Lower volume and continue playing',
                    /*2*/ 'Stop audio'
                  ],
                  initialIndex: 2,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: paddingHorizontal, vertical: 10),
              child: OutlinedButton.icon(
                //color: greyAccent,
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
                      "Developed by David Peters\nhttps://www.peterscode.dev",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
