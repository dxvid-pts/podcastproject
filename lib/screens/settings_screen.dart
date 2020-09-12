import 'dart:convert';
import 'dart:io';

//import 'dart:html' as webFile;
import 'package:flutter/foundation.dart';
import 'package:podcast_player/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:podcast_player/utils.dart';
import 'package:podcast_player/widgets/settings_section_widget.dart';
import 'package:progress_dialog/progress_dialog.dart';
import '../analyzer.dart';

const Color greyAccent = const Color(0x09000000);
const double paddingHorizontal = 26;

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      builder: (context, _isMobile, body) {
        return Scaffold(
          appBar: !_isMobile
              ? null
              : AppBar(
                  title: Text('Settings'),
                ),
          body: body,
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Backup your data',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                    Row(
                      children: [
                        OutlineButton(
                          onPressed: () async {
                            if (kIsWeb) {
                              /*final ProgressDialog pr = ProgressDialog(context);
                              pr.style(
                                  progressWidget: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue),
                                  ),
                                  message: 'Exporting data...');

                              await pr.show();

                              var blob = webFile.Blob(
                                  [export()], 'text/plain', 'native');

                              var anchorElement = webFile.AnchorElement(
                                  href:
                                      webFile.Url.createObjectUrlFromBlob(blob)
                                          .toString());
                              await pr.hide();
                              anchorElement
                                ..setAttribute("download", "data.pd")
                                ..click();*/
                            } else {
                              if (!await Permission.storage.request().isGranted)
                                return;

                              final String dirPath =
                                  await FilePicker.platform.getDirectoryPath();

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
                            }
                          },
                          child: Text('Export app data'),
                        ),
                        SizedBox(width: 10),
                        RaisedButton(
                          onPressed: () async {
                            if (kIsWeb) {
                              var r = await FilePicker.platform.pickFiles(
                                allowMultiple: false,
                                allowedExtensions: ['pd'],
                                type: FileType.custom,
                              );
                              if (r == null) return;

                              PlatformFile file = r.files.first;

                              final ProgressDialog pr = ProgressDialog(context);
                              pr.style(
                                  progressWidget: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue),
                                  ),
                                  message: 'Importing data from ${file.path}');

                              await pr.show();

                              print('import ${file.path}');

                              import(String.fromCharCodes(file.bytes));

                              await pr.hide();
                            } else {
                              if (!await Permission.storage.request().isGranted)
                                return;

                              var r = await FilePicker.platform.pickFiles(
                                allowMultiple: false,
                                allowedExtensions: ['pd'],
                                type: FileType.custom,
                              );
                              if (r == null) return;

                              File file = File(r.files.single.path);

                              if (!file.path.endsWith('.pd')) return;

                              final ProgressDialog pr = ProgressDialog(context);
                              pr.style(
                                  progressWidget: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue),
                                  ),
                                  message: 'Importing data from ${file.path}');

                              await pr.show();

                              print('import ${file.path}');
                              import(file.readAsStringSync());

                              await pr.hide();
                            }
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
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              children: [
                Expanded(
                    child: OutlineButton.icon(
                  //color: greyAccent,
                  icon: Icon(
                    Icons.code,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 19),
                    child: Text(
                      'Open-Source',
                    ),
                  ),
                  onPressed: () => openLinkInBrowser(
                      context, 'https://github.com/peterscodee/podcastproject'),
                )),
                SizedBox(width: 10),
                Expanded(
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
                )),
              ],
            ),
          ),
        ],
      ),
      valueListenable: isMobile,
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
      default:
        if (value.runtimeType.toString().contains('List')) {
          try {
            var list = value as List<dynamic>;
            List<String> stringList = List();
            for (var v in list) stringList.add(v.toString());

            prefs.setStringList(key, stringList);
          } catch (e) {
            print(e);
          }
        }

        break;
    }
  }
}
