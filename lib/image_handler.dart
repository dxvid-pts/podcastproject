import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart' as image;
import 'package:flutter/material.dart';
import 'package:podcast_player/widgets/skeleton_widget.dart';
import 'package:http/http.dart' as http;

Map<String, Uint8List> _ram = Map();
Map<String, Future<Uint8List>> _future = Map();

const imageResolution = 220;
const double defaultImageSize = 56;

class OptimizedImage extends StatelessWidget {
  final String url;
  final Function onTap;

  const OptimizedImage({Key key, @required this.url, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (_ram.containsKey(url)) {
      if (onTap == null)
        return Image.memory(_ram[url]);
      else {
        //TODO: Fix: https://github.com/flutter/flutter/issues/30193
        return Container(
          height: defaultImageSize,
          width: defaultImageSize,
          child: Ink.image(fit: BoxFit.cover,
            image: MemoryImage(_ram[url]),
            child: InkWell(
              onTap: onTap,
            ),
          ),
        );
      }
    }
    return Container(
      height: defaultImageSize,
      width: defaultImageSize,
      child: FutureBuilder<Uint8List>(
        future: loadImage(url),
        builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
          if (snapshot.hasData) {
            if (onTap == null)
              return Image.memory(snapshot.data);
            else
              return Ink.image(
                image: MemoryImage(snapshot.data),
                child: InkWell(
                  onTap: onTap,
                ),
              );
          } else
            return Skeleton(width: 60);
        },
      ),
    );
  }
}

Future<Uint8List> loadImage(final String url) async {
  _future.putIfAbsent(url, () => _loadImage(url));
  print(_future.length);
  return _future[url];
}

Future<Uint8List> _loadImage(final String url) async {
  var cache = await _getImageFromCache(url);
  print('a');
  if (cache != null) return cache;
  print('b');
  final resized = await _getResizedImage(url, imageResolution, imageResolution);

  _ram.putIfAbsent(url, () => resized);
  DefaultCacheManager().putFile(url, resized);

  return resized;
}

Future<Uint8List> _getResizedImage(
    final String url, final int height, final int width) {
  final List args = [url, height, width];
  return compute(_getResizedImageOnIsolate, args);
}

Future<Uint8List> _getResizedImageOnIsolate(final List args) async {
  final String url = args[0];
  final Uint8List data = (await http.get(url)).bodyBytes;
  final int height = args[1];
  final int width = args[2];
  image.Image baseSizeImage = image.decodeImage(data);
  image.Image resizeImage =
      image.copyResize(baseSizeImage, height: height, width: width);
  return image.encodeJpg(resizeImage);
}

Future<Uint8List> _getImageFromCache(final String url) async {
  final img = await DefaultCacheManager().getFileFromCache(url);

  if (img == null) {
    return null;
  }
  final u8 = await img.file.readAsBytes();
  _ram.putIfAbsent(url, () => u8);
  return u8;
}
