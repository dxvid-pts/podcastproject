import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podcast_player/analyzer/utils.dart';

class LastUpdatedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: lastUpdated,
      builder: (context, DateTime? dateTime, child) => StreamBuilder(
        stream: Stream.periodic(Duration(seconds: 5)),
        builder: (context, _) {
          if (dateTime == null) return Container();
          return Row(
            children: [
              child!,
              Text(
                DateTime.now().difference(dateTime).asReadableString,
                style: GoogleFonts.lexendDeca(fontSize: 13, color: Theme.of(context).brightness == Brightness.light ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.6)),
              ),
            ],
          );
        },
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 3),
        child: Icon(
          Icons.history,
          size: 14,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }
}

extension DurationString on Duration {
  String get asReadableString {
    if (inSeconds < 60) {
      if (inSeconds <= 10) return 'moments ago';
      return '${inSeconds}s ago';
    } else if (inMinutes < 60) {
      return '${inMinutes}min${inMinutes != 1 ? 's' : ''} ago';
    } else if (inHours < 24) {
      return '${inHours}h ago';
    }
    return '${inDays}day${inDays != 1 ? 's' : ''} ago';
  }
}
