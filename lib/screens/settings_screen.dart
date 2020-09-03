import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:podcast_player/widgets/settings_section_widget.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../analyzer.dart';

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
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: paddingHorizontal, vertical: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export & Import',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 16),
                        child: Text(
                          'Backup app data such as RSS feeds',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                      Row(
                        children: [
                          OutlineButton(
                            onPressed: () async {
                              if (!await Permission.storage.request().isGranted)
                                return;

                              final String dirPath =
                                  await FilePicker.getDirectoryPath();

                              final String filePath =
                                  dirPath + Platform.pathSeparator + 'data.pd';

                              print(dirPath);

                              final ProgressDialog pr = ProgressDialog(context);
                              pr.style(
                                  progressWidget: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue),
                                  ),
                                  message: 'Exporting data to $filePath');

                              await pr.show();

                              File file = File(filePath);
                              file.createSync();
                              file.writeAsStringSync(export());

                              await pr.hide();
                            },
                            child: Text('Export app data'),
                          ),
                          SizedBox(width: 10),
                          RaisedButton(
                            onPressed: () async {
                              if (!await Permission.storage.request().isGranted)
                                return;

                              File file = await FilePicker.getFile(
                                allowedExtensions: ['pd'],
                                type: FileType.custom,
                              );
                              if (!file.path.endsWith('.pd')) return;

                              print('import ${file.path}');
                              import(file.readAsStringSync());
                            },
                            child: Text('Import app data'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: paddingHorizontal, vertical: 10),
              child: OutlineButton.icon(
                //color: greyAccent,
                icon: Icon(
                  Icons.assignment_outlined,
                  color: Colors.black.withOpacity(0.6),
                ),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 19),
                  child: Text('View licenses'),
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

String export() {
  Map<String, dynamic> data = Map();
  for (String key in prefs.getKeys())
    data.putIfAbsent(key, () => prefs.get(key));

  return jsonEncode(data);
}

void import(String json) {
  Map<String, dynamic> data = jsonDecode(json);
  for (final String key in data.keys) {
    final value = data[key];
    switch (value.runtimeType) {
      case String:
        prefs.setString(key, value);
        break;
      case int:
        prefs.setInt(key, value);
        break;
      //TODO: Not working yet
      case Iterable:
        prefs.setStringList(key, value);
        break;
    }
    print(value.runtimeType.toString());
  }
}
