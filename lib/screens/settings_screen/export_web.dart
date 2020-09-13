// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:podcast_player/screens/settings_screen/settings_screen.dart';

void saveExport(){
  var blob = Blob(
      [export()], 'text/plain', 'native');

  var anchorElement = AnchorElement(
      href:
      Url.createObjectUrlFromBlob(blob)
          .toString());
  anchorElement
    ..setAttribute("download", "data.pd")
    ..click();
}