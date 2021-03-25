import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podcast_player/analyzer/utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../main.dart';
import 'podcast_list_tile.dart';

class PodcastGrid extends ConsumerWidget {
  const PodcastGrid({Key? key, this.crossAxisCount = 4}) : super(key: key);

  final int crossAxisCount;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final isMobile = watch(layoutProvider).isMobile;

    return StreamBuilder<Set<Podcast>>(
      initialData: podcastProvider.currentState.values.toSet(),
      stream: podcastProvider.podcasts,
      builder: (context, AsyncSnapshot<Set<Podcast>> snapshot) {
        if (!snapshot.hasData) return Text("No data");

        List<Widget> widgetList = <Widget>[]..addAll(snapshot.data!.map(
            (podcast) => PodcastListTile(
              child: podcast.img == null
                  ? Container()
                  : Image.network(podcast.img!),
              tooltip: podcast.title,
              onTap: () => print(podcast.title),
            ),
          ));
        widgetList.add(PodcastListTile(
          child: Center(child: Icon(Icons.add)),
          tooltip: "Add podcast",
          onTap: () => print("add"),
        ));

        final int rows = (widgetList.length / crossAxisCount).floor();
        final int _maxRows = isMobile ? 3 : 2;
        final int pages = (rows / _maxRows).floor();

        if (pages <= 1) {
          return _PodcastGridPage(crossAxisCount: crossAxisCount, children: widgetList);
        } else {
          return _MultiPagePodcastGrid(crossAxisCount: crossAxisCount, children: widgetList);
        }
      },
    );
  }
}

class _PodcastGridPage extends StatelessWidget {
  const _PodcastGridPage(
      {required this.crossAxisCount, required this.children, GlobalKey? key})
      : super(key: key);

  final int crossAxisCount;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => GridView.count(
        primary: false,
        shrinkWrap: true,
        padding: const EdgeInsets.all(5),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        children: children,
      );
}

class _MultiPagePodcastGrid extends StatefulWidget {
  const _MultiPagePodcastGrid({
    Key? key,
    required this.crossAxisCount,
    required this.children,
  }) : super(key: key);

  final int crossAxisCount;
  final List<Widget> children;

  @override
  _ChildDependentBuilderState createState() => _ChildDependentBuilderState();
}

class _ChildDependentBuilderState extends State<_MultiPagePodcastGrid> {
  final List<Widget> _pageList = [];
  List<Widget> _firstPage = [];
  double height = 0;
  GlobalKey _k = GlobalKey();
  PageController _controller = PageController();

  @override
  void initState() {
    print("init");
    List<Widget> _page = [];
    for (Widget w in widget.children) {
      print("uaa");
      _page.add(w);

      if (_page.length == widget.crossAxisCount) {
        if (_pageList.isEmpty) {
          _firstPage = _page;
        }

        _pageList.add(_PodcastGridPage(
            crossAxisCount: widget.crossAxisCount, children: _page));
        print(_pageList);
        _page = [];
      }
    }

    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      final cContext = _k.currentContext;
      if (cContext != null && cContext.size != null)
        setState(() {
          print("b");
          height = cContext.size!.height;
        });

      print('the new height is $height');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Opacity(
              opacity: height == 0 ? 1 : 0,
              child: _PodcastGridPage(
                key: _k,
                crossAxisCount: widget.crossAxisCount,
                children: _firstPage,
              ),
            ),
            SizedBox(
              height: height,
              child: PageView.builder(
                controller: _controller,
                itemCount: _pageList.length,
                itemBuilder: (context, index) => _pageList[index],
              ),
            ),
          ],
        ),
        SmoothPageIndicator(
            controller: _controller,
            // PageController
            count: _pageList.length,
            effect: WormEffect(
              dotHeight: 6,
              dotWidth: 6,
              spacing: 4,
              activeDotColor: Theme.of(context).accentColor,
              dotColor: Colors.black.withOpacity(0.2),
            ),
            onDotClicked: (index) {
              _controller.animateToPage(index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn);
            }),
      ],
    );
  }
}
